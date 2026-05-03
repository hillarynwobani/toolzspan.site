// MP3 Converter - bidirectional audio converter
// Inputs:  MP3, WAV, OGG, FLAC, M4A
// Outputs: MP3, WAV, OGG, FLAC (user-selectable via 'output' field)
// Engine: FFmpeg (Node) - per v9.1 expanded scope

const { makeFfmpegHandler } = require('./_lib/handler');

const CODEC_BY_EXT = {
  mp3:  ['-codec:a', 'libmp3lame', '-b:a', '192k'],
  wav:  ['-codec:a', 'pcm_s16le'],
  ogg:  ['-codec:a', 'libvorbis', '-q:a', '5'],
  flac: ['-codec:a', 'flac', '-compression_level', '5']
};

const MIME_BY_EXT = {
  mp3:  'audio/mpeg',
  wav:  'audio/wav',
  ogg:  'audio/ogg',
  flac: 'audio/flac'
};

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac'],
  maxBytes: 200 * 1024 * 1024,
  outputExt: (fields) => {
    const requested = (fields.output || 'mp3').toLowerCase();
    return CODEC_BY_EXT[requested] ? requested : 'mp3';
  },
  outputMime: (ext) => MIME_BY_EXT[ext] || 'application/octet-stream',
  buildArgs: (file, fields, ext) => {
    const codec = CODEC_BY_EXT[ext] || CODEC_BY_EXT.mp3;
    return ['-vn', ...codec];
  }
});
