// Excel to PDF - server-side via libreoffice-convert
// Requires LibreOffice on the host. On Netlify free tier this may need a custom build step
// or a third-party binary layer. If unavailable, function will return a 503.
const path = require('path');
const fs = require('fs').promises;
const os = require('os');
const crypto = require('crypto');
const { promisify } = require('util');
const { parseMultipart, cleanup, jsonError, binaryResponse, preflight } = require('./_lib/handler');

let libre;
try { libre = require('libreoffice-convert'); } catch (_) { libre = null; }

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return preflight();
  if (event.httpMethod !== 'POST') return jsonError(405, 'Method not allowed');

  if (!libre) {
    return jsonError(503, 'libreoffice-convert is not installed. Run npm install on the deployment.');
  }

  let parsed;
  try { parsed = await parseMultipart(event, { maxBytes: 15 * 1024 * 1024 }); }
  catch (err) { return jsonError(400, err.message); }

  const { file } = parsed;
  const allowed = ['xls', 'xlsx', 'ods', 'csv'];
  const ext = path.extname(file.name).toLowerCase().replace('.', '');
  if (!allowed.includes(ext)) {
    await cleanup(file.tmpPath);
    return jsonError(400, `Unsupported input format: ${ext}`);
  }

  let inputBuffer;
  try { inputBuffer = await fs.readFile(file.tmpPath); }
  catch (err) {
    cleanup(file.tmpPath);
    return jsonError(500, `Failed to read upload: ${err.message}`);
  }

  const convert = promisify(libre.convert);
  try {
    const pdfBuffer = await convert(inputBuffer, '.pdf', undefined);
    cleanup(file.tmpPath);
    const baseName = path.parse(file.name).name;
    return binaryResponse(pdfBuffer, `${baseName}.pdf`, 'application/pdf');
  } catch (err) {
    cleanup(file.tmpPath);
    return jsonError(500, `LibreOffice conversion failed: ${err.message || err}`);
  }
};