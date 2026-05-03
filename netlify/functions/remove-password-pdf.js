// Remove Password from PDF - uses node-qpdf2 (requires qpdf binary on host)
// Field: password (required - the existing password to unlock with)
const path = require('path');
const fs = require('fs');
const os = require('os');
const crypto = require('crypto');
const { parseMultipart, cleanup, jsonError, binaryResponse, preflight } = require('./_lib/handler');

let qpdf;
try { qpdf = require('node-qpdf2'); } catch (_) { qpdf = null; }

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return preflight();
  if (event.httpMethod !== 'POST') return jsonError(405, 'Method not allowed');

  if (!qpdf) {
    return jsonError(503, 'node-qpdf2 is not installed. Run npm install on the deployment.');
  }

  let parsed;
  try { parsed = await parseMultipart(event, { maxBytes: 100 * 1024 * 1024 }); }
  catch (err) { return jsonError(400, err.message); }

  const { file, fields } = parsed;
  const password = (fields.password || '').toString();
  if (!password) {
    cleanup(file.tmpPath);
    return jsonError(400, 'Password field is required to unlock the PDF');
  }
  if (path.extname(file.name).toLowerCase() !== '.pdf') {
    cleanup(file.tmpPath);
    return jsonError(400, 'Only .pdf files are accepted');
  }

  const outPath = path.join(os.tmpdir(), `${crypto.randomBytes(8).toString('hex')}-unlocked.pdf`);

  try {
    await qpdf.decrypt({
      input: file.tmpPath,
      output: outPath,
      password
    });
    const buf = fs.readFileSync(outPath);
    cleanup(file.tmpPath, outPath);
    const baseName = path.parse(file.name).name;
    return binaryResponse(buf, `${baseName}-unlocked.pdf`, 'application/pdf');
  } catch (err) {
    cleanup(file.tmpPath, outPath);
    return jsonError(500, `qpdf decrypt failed: ${err.message || err}`);
  }
};