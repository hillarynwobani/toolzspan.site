// AVI to MP4 converter
const { makeFfmpegHandler } = require('./_lib/handler');

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['avi'],
  outputExt: 'mp4',
  outputMime: 'video/mp4',
  maxBytes: 50 * 1024 * 1024,
  buildArgs: () => [
    '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '23',
    '-c:a', 'aac', '-b:a', '128k',
    '-movflags', '+faststart'
  ]
});