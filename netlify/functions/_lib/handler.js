// Shared helpers for Toolzspan Netlify Functions
// - Multipart form parsing (busboy)
// - Temp file management
// - Standard error/success response shape
// - FFmpeg runner factory

const Busboy = require('busboy');
const fs = require('fs');
const path = require('path');
const os = require('os');
const crypto = require('crypto');
const { execFile } = require('child_process');
const { promisify } = require('util');
const execFileP = promisify(execFile);

// ----- Response helpers -----

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  };
}

function jsonError(statusCode, message) {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json', ...corsHeaders() },
    body: JSON.stringify({ error: message })
  };
}

function binaryResponse(buffer, filename, mimeType) {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': mimeType,
      'Content-Disposition': `attachment; filename="${filename}"`,
      ...corsHeaders()
    },
    body: buffer.toString('base64'),
    isBase64Encoded: true
  };
}

function preflight() {
  return { statusCode: 204, headers: corsHeaders(), body: '' };
}

// ----- Multipart parser -----
// Returns { file: { name, size, tmpPath, mimeType }, fields: { ... } }

function parseMultipart(event, opts = {}) {
  const maxBytes = opts.maxBytes || 50 * 1024 * 1024; // 50MB default
  return new Promise((resolve, reject) => {
    const contentType = event.headers['content-type'] || event.headers['Content-Type'];
    if (!contentType || !contentType.includes('multipart/form-data')) {
      return reject(new Error('Expected multipart/form-data'));
    }
    const bb = Busboy({ headers: { 'content-type': contentType }, limits: { fileSize: maxBytes, files: 1 } });
    const fields = {};
    let fileInfo = null;
    let fileTooLarge = false;

    bb.on('file', (name, stream, info) => {
      const tmpPath = path.join(os.tmpdir(), `${crypto.randomBytes(8).toString('hex')}-${info.filename}`);
      const out = fs.createWriteStream(tmpPath);
      let bytes = 0;
      stream.on('data', (chunk) => { bytes += chunk.length; });
      stream.on('limit', () => { fileTooLarge = true; });
      stream.pipe(out);
      out.on('close', () => {
        fileInfo = { name: info.filename, size: bytes, tmpPath, mimeType: info.mimeType };
      });
    });

    bb.on('field', (name, val) => { fields[name] = val; });
    bb.on('error', reject);
    bb.on('close', () => {
      if (fileTooLarge) return reject(new Error(`File exceeds maximum size of ${(maxBytes / 1024 / 1024).toFixed(0)}MB`));
      if (!fileInfo) return reject(new Error('No file uploaded'));
      resolve({ file: fileInfo, fields });
    });

    const body = event.isBase64Encoded ? Buffer.from(event.body, 'base64') : Buffer.from(event.body || '', 'binary');
    bb.end(body);
  });
}

// ----- Cleanup -----

function cleanup(...paths) {
  for (const p of paths) {
    if (!p) continue;
    try { fs.unlinkSync(p); } catch (_) { /* ignore */ }
  }
}

// ----- FFmpeg runner -----
// Returns a Buffer of the output file.

let _ffmpegPath = null;
function getFfmpegPath() {
  if (_ffmpegPath) return _ffmpegPath;
  try {
    _ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
  } catch (e) {
    _ffmpegPath = 'ffmpeg'; // fallback to system ffmpeg
  }
  return _ffmpegPath;
}

async function runFfmpeg(inputPath, outputExt, args) {
  const outPath = path.join(os.tmpdir(), `${crypto.randomBytes(8).toString('hex')}.${outputExt}`);
  const ffmpeg = getFfmpegPath();
  // Standard arg pattern: ['-i', inputPath, ...args, outPath]
  const fullArgs = ['-y', '-i', inputPath, ...args, outPath];
  try {
    await execFileP(ffmpeg, fullArgs, { maxBuffer: 1024 * 1024 * 100 }); // 100MB stdout buffer
    const buf = fs.readFileSync(outPath);
    cleanup(outPath);
    return buf;
  } catch (err) {
    cleanup(outPath);
    const stderr = (err.stderr || '').toString().split('\n').slice(-5).join('\n');
    throw new Error(`FFmpeg failed: ${stderr || err.message}`);
  }
}

// ----- Standard FFmpeg handler factory -----
// Pass a function that takes { inputPath, outputExt, fields } and returns FFmpeg args array.

function makeFfmpegHandler({ allowedExtensions, outputExt, outputMime, maxBytes, buildArgs, defaultOutName }) {
  return async (event) => {
    if (event.httpMethod === 'OPTIONS') return preflight();
    if (event.httpMethod !== 'POST') return jsonError(405, 'Method not allowed');

    let parsed;
    try {
      parsed = await parseMultipart(event, { maxBytes });
    } catch (err) {
      return jsonError(400, err.message);
    }

    const { file, fields } = parsed;

    // Optional input format check
    if (allowedExtensions && allowedExtensions.length) {
      const ext = path.extname(file.name).toLowerCase().replace('.', '');
      if (!allowedExtensions.includes(ext)) {
        cleanup(file.tmpPath);
        return jsonError(400, `Unsupported input format: ${ext}. Allowed: ${allowedExtensions.join(', ')}`);
      }
    }

    // Determine output extension (some tools allow user choice)
    const ext = (typeof outputExt === 'function') ? outputExt(fields, file) : outputExt;

    let outputBuffer;
    try {
      const args = buildArgs(file, fields, ext);
      outputBuffer = await runFfmpeg(file.tmpPath, ext, args);
    } catch (err) {
      cleanup(file.tmpPath);
      return jsonError(500, err.message);
    }

    cleanup(file.tmpPath);

    const baseName = path.parse(file.name).name;
    const outName = (defaultOutName ? defaultOutName(baseName, ext, fields) : `${baseName}.${ext}`);
    const mime = (typeof outputMime === 'function') ? outputMime(ext) : outputMime;

    return binaryResponse(outputBuffer, outName, mime);
  };
}

module.exports = {
  corsHeaders,
  jsonError,
  binaryResponse,
  preflight,
  parseMultipart,
  cleanup,
  getFfmpegPath,
  runFfmpeg,
  makeFfmpegHandler
};
