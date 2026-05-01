// Audio Compressor - reduce audio bitrate. Supports MP3, WAV, OGG, M4A, AAC, FLAC.
const { makeFfmpegHandler } = require('./_lib/handler');

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac'],
  outputExt: 'mp3',
  outputMime: 'audio/mpeg',
  maxBytes: 30 * 1024 * 1024,
  buildArgs: (file, fields) => {
    const validBitrates = ['64k', '96k', '128k', '160k', '192k'];
    const bitrate = validBitrates.includes(fields.bitrate) ? fields.bitrate : '128k';
    return ['-vn', '-codec:a', 'libmp3lame', '-b:a', bitrate];
  },
  defaultOutName: (base) => `${base}-compressed.mp3`
});