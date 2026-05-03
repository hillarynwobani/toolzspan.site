// GIF Converter - GIF <-> MP4
// Output via 'output' field: 'mp4' (default) or 'gif'
const path = require('path');
const fs = require('fs');
const os = require('os');
const crypto = require('crypto');
const { execFile } = require('child_process');
const { promisify } = require('util');
const execFileP = promisify(execFile);
const { parseMultipart, cleanup, getFfmpegPath, jsonError, binaryResponse, preflight } = require('./_lib/handler');

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return preflight();
  if (event.httpMethod !== 'POST') return jsonError(405, 'Method not allowed');

  let parsed;
  try { parsed = await parseMultipart(event, { maxBytes: 500 * 1024 * 1024 }); }
  catch (err) { return jsonError(400, err.message); }

  const { file, fields } = parsed;
  const inExt = path.extname(file.name).toLowerCase().replace('.', '');
  const out = (fields.output || 'mp4').toLowerCase();

  if (!['gif', 'mp4', 'webm'].includes(inExt)) {
    cleanup(file.tmpPath);
    return jsonError(400, `Unsupported input: ${inExt}. Allowed: gif, mp4, webm`);
  }

  const ffmpeg = getFfmpegPath();
  const outPath = path.join(os.tmpdir(), `${crypto.randomBytes(8).toString('hex')}.${out}`);

  let args;
  if (out === 'mp4') {
    args = ['-y', '-i', file.tmpPath,
      '-movflags', '+faststart', '-pix_fmt', 'yuv420p',
      '-vf', 'scale=trunc(iw/2)*2:trunc(ih/2)*2',
      '-c:v', 'libx264', '-preset', 'fast', '-crf', '23',
      outPath];
  } else if (out === 'gif') {
    args = ['-y', '-i', file.tmpPath,
      '-vf', 'fps=10,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse',
      '-loop', '0', outPath];
  } else {
    cleanup(file.tmpPath);
    return jsonError(400, `Unsupported output: ${out}`);
  }

  try {
    await execFileP(ffmpeg, args, { maxBuffer: 1024 * 1024 * 100 });
    const buf = fs.readFileSync(outPath);
    cleanup(file.tmpPath, outPath);
    const mime = out === 'mp4' ? 'video/mp4' : 'image/gif';
    return binaryResponse(buf, `${path.parse(file.name).name}.${out}`, mime);
  } catch (err) {
    cleanup(file.tmpPath, outPath);
    const stderr = (err.stderr || '').toString().split('\n').slice(-5).join('\n');
    return jsonError(500, `FFmpeg failed: ${stderr || err.message}`);
  }
};