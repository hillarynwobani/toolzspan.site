// PDF to Word - extract text via pdfjs-dist + assemble with the docx package
// NOTE: This is a JS implementation. Layout fidelity is lower than Python pdf2docx.
// For high-fidelity output, switch to a Python runtime with pdf2docx (per v9.1 Section 4B).
const path = require('path');
const fs = require('fs');
const { parseMultipart, cleanup, jsonError, binaryResponse, preflight } = require('./_lib/handler');

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return preflight();
  if (event.httpMethod !== 'POST') return jsonError(405, 'Method not allowed');

  let pdfjs, docxLib;
  try {
    pdfjs = await import('pdfjs-dist/legacy/build/pdf.mjs');
    docxLib = require('docx');
  } catch (err) {
    return jsonError(503, 'PDF parsing libs not available: ' + err.message);
  }

  let parsed;
  try { parsed = await parseMultipart(event, { maxBytes: 100 * 1024 * 1024 }); }
  catch (err) { return jsonError(400, err.message); }

  const { file } = parsed;
  if (path.extname(file.name).toLowerCase() !== '.pdf') {
    cleanup(file.tmpPath);
    return jsonError(400, 'Only .pdf files are accepted');
  }

  try {
    const data = new Uint8Array(fs.readFileSync(file.tmpPath));
    const pdfDoc = await pdfjs.getDocument({ data }).promise;
    const paragraphs = [];
    const { Document, Packer, Paragraph, TextRun } = docxLib;
    for (let i = 1; i <= pdfDoc.numPages; i++) {
      const page = await pdfDoc.getPage(i);
      const content = await page.getTextContent();
      const text = content.items.map((it) => ('str' in it ? it.str : '')).join(' ');
      paragraphs.push(new Paragraph({ children: [new TextRun(text)] }));
      paragraphs.push(new Paragraph(''));
    }
    const doc = new Document({ sections: [{ children: paragraphs }] });
    const buffer = await Packer.toBuffer(doc);
    cleanup(file.tmpPath);
    const baseName = path.parse(file.name).name;
    return binaryResponse(buffer, `${baseName}.docx`, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
  } catch (err) {
    cleanup(file.tmpPath);
    return jsonError(500, `PDF to Word conversion failed: ${err.message}`);
  }
};