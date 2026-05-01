// MP4 Converter - re-encode any video to MP4 (H.264/AAC)
const { makeFfmpegHandler } = require('./_lib/handler');

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['mp4', 'avi', 'mov', 'mkv', 'webm', 'flv', 'wmv', '3gp', 'm4v'],
  outputExt: 'mp4',
  outputMime: 'video/mp4',
  maxBytes: 50 * 1024 * 1024,
  buildArgs: () => [
    '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '23',
    '-c:a', 'aac', '-b:a', '128k',
    '-movflags', '+faststart'
  ]
});