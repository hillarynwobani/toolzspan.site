// Compress MP3 - reduce bitrate. Default 96kbps, user-selectable via 'bitrate' field.
const { makeFfmpegHandler } = require('./_lib/handler');

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['mp3'],
  outputExt: 'mp3',
  outputMime: 'audio/mpeg',
  maxBytes: 200 * 1024 * 1024,
  buildArgs: (file, fields) => {
    const validBitrates = ['64k', '96k', '128k', '160k', '192k'];
    const bitrate = validBitrates.includes(fields.bitrate) ? fields.bitrate : '96k';
    return ['-vn', '-codec:a', 'libmp3lame', '-b:a', bitrate];
  },
  defaultOutName: (base) => `${base}-compressed.mp3`
});
