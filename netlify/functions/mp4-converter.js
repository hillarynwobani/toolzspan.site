// MP4 Converter - bidirectional video converter
// Inputs:  MP4, AVI, MOV, WebM, MKV, FLV, WMV
// Outputs: MP4, AVI, MOV, WebM, MKV (user-selectable via 'output' field)
// Engine: FFmpeg (Node)

const { makeFfmpegHandler } = require('./_lib/handler');

// Per-output codec args. Audio always re-encoded; video chosen for compatibility.
const CODEC_BY_EXT = {
  mp4:  ['-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '23',
         '-c:a', 'aac', '-b:a', '128k',
         '-movflags', '+faststart'],
  avi:  ['-c:v', 'mpeg4', '-vtag', 'xvid', '-qscale:v', '5',
         '-c:a', 'libmp3lame', '-b:a', '128k'],
  mov:  ['-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '23',
         '-c:a', 'aac', '-b:a', '128k',
         '-movflags', '+faststart'],
  webm: ['-c:v', 'libvpx-vp9', '-b:v', '1M', '-deadline', 'realtime', '-cpu-used', '8',
         '-c:a', 'libopus', '-b:a', '128k'],
  mkv:  ['-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '23',
         '-c:a', 'aac', '-b:a', '128k']
};

const MIME_BY_EXT = {
  mp4:  'video/mp4',
  avi:  'video/x-msvideo',
  mov:  'video/quicktime',
  webm: 'video/webm',
  mkv:  'video/x-matroska'
};

exports.handler = makeFfmpegHandler({
  allowedExtensions: ['mp4', 'avi', 'mov', 'mkv', 'webm', 'flv', 'wmv', '3gp', 'm4v'],
  maxBytes: 500 * 1024 * 1024,
  outputExt: (fields) => {
    const requested = (fields.output || 'mp4').toLowerCase();
    return CODEC_BY_EXT[requested] ? requested : 'mp4';
  },
  outputMime: (ext) => MIME_BY_EXT[ext] || 'video/mp4',
  buildArgs: (file, fields, ext) => {
    const codec = CODEC_BY_EXT[ext] || CODEC_BY_EXT.mp4;
    return [...codec];
  }
});