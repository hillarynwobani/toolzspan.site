// OGG to MP3 converter - server-side via FFmpeg
const { makeFfmpegHandler } = require('./_lib/handler');

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['ogg', 'oga'],
  outputExt: 'mp3',
  outputMime: 'audio/mpeg',
  maxBytes: 200 * 1024 * 1024,
  buildArgs: () => ['-vn', '-codec:a', 'libmp3lame', '-b:a', '192k']
});
