// MOV to MP4 converter (commonly iPhone videos)
const { makeFfmpegHandler } = require('./_lib/handler');

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['mov', 'qt'],
  outputExt: 'mp4',
  outputMime: 'video/mp4',
  maxBytes: 500 * 1024 * 1024,
  buildArgs: () => [
    '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '23',
    '-c:a', 'aac', '-b:a', '128k',
    '-movflags', '+faststart'
  ]
});