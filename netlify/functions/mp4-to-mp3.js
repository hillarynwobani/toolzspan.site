// MP4 to MP3 - extract audio track from video
const { makeFfmpegHandler } = require('./_lib/handler');

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['mp4', 'm4v'],
  outputExt: 'mp3',
  outputMime: 'audio/mpeg',
  maxBytes: 30 * 1024 * 1024,
  buildArgs: () => ['-vn', '-codec:a', 'libmp3lame', '-b:a', '192k']
});