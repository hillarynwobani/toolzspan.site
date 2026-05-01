// GIF Maker - turn a video clip into an animated GIF
// Optional fields: width (default 480), fps (default 10), startSec, durationSec
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
  try { parsed = await parseMultipart(event, { maxBytes: 30 * 1024 * 1024 }); }
  catch (err) { return jsonError(400, err.message); }

  const { file, fields } = parsed;
  const width = Math.min(Math.max(parseInt(fields.width, 10) || 480, 120), 1280);
  const fps = Math.min(Math.max(parseInt(fields.fps, 10) || 10, 5), 24);
  const start = parseFloat(fields.startSec) || 0;
  const duration = parseFloat(fields.durationSec) || 0;

  const outPath = path.join(os.tmpdir(), `${crypto.randomBytes(8).toString('hex')}.gif`);
  const ffmpeg = getFfmpegPath();

  const trimArgs = [];
  if (start > 0) trimArgs.push('-ss', String(start));
  if (duration > 0) trimArgs.push('-t', String(duration));

  // Two-pass palette workflow inline using palettegen + paletteuse
  const filter = `fps=${fps},scale=${width}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse`;
  const args = ['-y', ...trimArgs, '-i', file.tmpPath, '-vf', filter, '-loop', '0', outPath];

  try {
    await execFileP(ffmpeg, args, { maxBuffer: 1024 * 1024 * 100 });
    const buf = fs.readFileSync(outPath);
    cleanup(file.tmpPath, outPath);
    return binaryResponse(buf, `${path.parse(file.name).name}.gif`, 'image/gif');
  } catch (err) {
    cleanup(file.tmpPath, outPath);
    const stderr = (err.stderr || '').toString().split('\n').slice(-5).join('\n');
    return jsonError(500, `FFmpeg failed: ${stderr || err.message}`);
  }
};