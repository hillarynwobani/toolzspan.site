// MP3 to MP4 - audio with a black static image as video track
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
  try {
    parsed = await parseMultipart(event, { maxBytes: 30 * 1024 * 1024 });
  } catch (err) {
    return jsonError(400, err.message);
  }

  const { file } = parsed;
  const ext = path.extname(file.name).toLowerCase().replace('.', '');
  if (!['mp3', 'wav', 'ogg', 'flac'].includes(ext)) {
    cleanup(file.tmpPath);
    return jsonError(400, `Unsupported input format: ${ext}`);
  }

  const outPath = path.join(os.tmpdir(), `${crypto.randomBytes(8).toString('hex')}.mp4`);
  const ffmpeg = getFfmpegPath();

  // Audio + 1-frame black 1280x720 PNG as video track, encoded with libx264
  const args = [
    '-y',
    '-f', 'lavfi', '-i', 'color=c=black:s=1280x720:r=1',
    '-i', file.tmpPath,
    '-c:v', 'libx264', '-tune', 'stillimage', '-preset', 'ultrafast',
    '-c:a', 'aac', '-b:a', '192k',
    '-shortest', '-pix_fmt', 'yuv420p',
    outPath
  ];

  try {
    await execFileP(ffmpeg, args, { maxBuffer: 1024 * 1024 * 100 });
    const buf = fs.readFileSync(outPath);
    cleanup(file.tmpPath, outPath);
    return binaryResponse(buf, `${path.parse(file.name).name}.mp4`, 'video/mp4');
  } catch (err) {
    cleanup(file.tmpPath, outPath);
    const stderr = (err.stderr || '').toString().split('\n').slice(-5).join('\n');
    return jsonError(500, `FFmpeg failed: ${stderr || err.message}`);
  }
};