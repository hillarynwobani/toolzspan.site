// Compress MP4 - optimised compression preset
const { makeFfmpegHandler } = require('./_lib/handler');

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['mp4'],
  outputExt: 'mp4',
  outputMime: 'video/mp4',
  maxBytes: 50 * 1024 * 1024,
  buildArgs: (file, fields) => {
    const crfNum = parseInt(fields.crf, 10);
    const crf = (crfNum >= 18 && crfNum <= 32) ? String(crfNum) : '28';
    return [
      '-c:v', 'libx264', '-preset', 'fast', '-crf', crf,
      '-c:a', 'aac', '-b:a', '96k',
      '-movflags', '+faststart'
    ];
  },
  defaultOutName: (base) => `${base}-compressed.mp4`
});