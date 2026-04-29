// Netlify Function stub — MP4 Converter
// Requires: FFmpeg installed on Netlify build image
// Deploy with netlify.toml: [functions] directory = "netlify/functions"
exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'Method Not Allowed' };
  return { statusCode: 200, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ status: 'ready', message: 'MP4 Converter endpoint. Deploy with FFmpeg to enable processing.' }) };
};
