# Toolzspan: Netlify → Oracle Cloud Migration Guide

## Executive Summary

Migrate 21 serverless file-processing functions from Netlify Functions to Oracle Cloud Infrastructure (OCI). The frontend is a static HTML site (104 pages) currently hosted on Netlify. The functions accept file uploads via multipart/form-data, process them (FFmpeg, LibreOffice, qpdf, PDF parsing), and return binary output. The frontend must remain deployable as static files with a single endpoint change.

---

## 1. Current Architecture

### Static Frontend
- **104 HTML pages** (index + 50 tools + 24 blog posts + utility pages)
- **Hosted on:** Netlify CDN
- **Domain:** toolzspan.site
- **Framework:** None (vanilla HTML/CSS/JS, no build step)
- **Assets:** `css/style.css` (45KB), `js/main.js` (10KB), `js/search.js` (21KB), `js/server-tool.js` (5.4KB)

### Serverless Backend
- **Platform:** Netlify Functions (AWS Lambda under the hood)
- **Runtime:** Node.js 18.x
- **Bundler:** esbuild
- **Function timeout:** 26 seconds (Pro tier)
- **Ephemeral disk:** 512MB /tmp
- **Max upload:** 500MB (video tools), 200MB (audio), 100MB (PDF/office)

### Client-Server Contract
The frontend (`js/server-tool.js`) POSTs `multipart/form-data` to `/.netlify/functions/<name>` and expects:
- **Success:** HTTP 200, `Content-Type` (binary mime), `Content-Disposition: attachment; filename="..."`, body = raw binary (base64-encoded in Netlify's response format)
- **Error:** HTTP 4xx/5xx, JSON body `{ "error": "message" }`
- **CORS:** `Access-Control-Allow-Origin: *`

---

## 2. Complete Function Inventory (21 Functions)

### Category A: FFmpeg-Based (14 functions)
These use `@ffmpeg-installer/ffmpeg` or system FFmpeg binary.

| # | Function | Input Formats | Output | Max Upload | Extra Fields |
|---|----------|--------------|--------|-----------|--------------|
| 1 | `audio-compressor` | mp3, wav, ogg, m4a, aac, flac | mp3 | 200MB | `bitrate` (64k/96k/128k/160k/192k) |
| 2 | `avi-to-mp4` | avi | mp4 | 500MB | none |
| 3 | `compress-mp3` | mp3 | mp3 | 200MB | `bitrate` (64k/96k/128k/160k/192k) |
| 4 | `compress-mp4` | mp4 | mp4 | 500MB | `crf` (18-32) |
| 5 | `gif-converter` | gif, mp4, webm | gif or mp4 | 500MB | `output` (mp4/gif) |
| 6 | `gif-maker` | any video | gif | 500MB | `width`, `fps`, `startSec`, `durationSec` |
| 7 | `mov-to-mp4` | mov, qt | mp4 | 500MB | none |
| 8 | `mp3-converter` | mp3, wav, ogg, flac, m4a, aac | mp3/wav/ogg/flac | 200MB | `output` (mp3/wav/ogg/flac) |
| 9 | `mp3-to-mp4` | mp3, wav, ogg, flac | mp4 (with black video) | 200MB | none |
| 10 | `mp4-converter` | mp4, avi, mov, mkv, webm, flv, wmv, 3gp, m4v | mp4/avi/mov/webm/mkv | 500MB | `output` (mp4/avi/mov/webm/mkv) |
| 11 | `mp4-to-mp3` | mp4, m4v | mp3 | 500MB | none |
| 12 | `ogg-to-mp3` | ogg, oga | mp3 | 200MB | none |
| 13 | `video-compressor` | mp4, avi, mov, mkv, webm, m4v | mp4 | 500MB | `crf` (18-32) |
| 14 | `wav-to-mp3` | wav | mp3 | 200MB | none |
| 15 | `webm-to-mp4` | webm | mp4 | 500MB | none |

### Category B: LibreOffice-Based (3 functions)
These require LibreOffice installed on the host for document conversion.

| # | Function | Input Formats | Output | Max Upload | Notes |
|---|----------|--------------|--------|-----------|-------|
| 16 | `excel-to-pdf` | xls, xlsx, ods, csv | pdf | 100MB | Uses `libreoffice-convert` |
| 17 | `powerpoint-to-pdf` | ppt, pptx, odp | pdf | 100MB | Uses `libreoffice-convert` |
| 18 | `word-to-pdf` | doc, docx, odt, rtf | pdf | 100MB | Uses `libreoffice-convert` |

### Category C: qpdf-Based (2 functions)
These require the `qpdf` binary on the host for PDF encryption/decryption.

| # | Function | Input Formats | Output | Max Upload | Extra Fields |
|---|----------|--------------|--------|-----------|--------------|
| 19 | `add-password-pdf` | pdf | pdf | 100MB | `password` (required) |
| 20 | `remove-password-pdf` | pdf | pdf | 100MB | `password` (required, existing password) |

### Category D: Pure Node.js (1 function)
| # | Function | Input Formats | Output | Max Upload | Notes |
|---|----------|--------------|--------|-----------|-------|
| 21 | `pdf-to-word` | pdf | docx | 100MB | Uses `pdfjs-dist` + `docx` package |

---

## 3. System Dependencies Required on Oracle

| Dependency | Used By | Install Command (Oracle Linux/Ubuntu) |
|-----------|---------|--------------------------------------|
| **FFmpeg** (with libx264, libmp3lame, libvorbis, libopus, libvpx-vp9) | 15 functions (Cat A) | `dnf install ffmpeg` or compile from source |
| **LibreOffice** (headless) | 3 functions (Cat B) | `dnf install libreoffice-headless` |
| **qpdf** | 2 functions (Cat C) | `dnf install qpdf` |
| **Node.js 18+** | All | `dnf install nodejs` or nvm |

---

## 4. NPM Dependencies (package.json)

```json
{
  "name": "toolzspan-functions",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@ffmpeg-installer/ffmpeg": "^1.1.0",
    "fluent-ffmpeg": "^2.1.3",
    "busboy": "^1.6.0",
    "libreoffice-convert": "^1.6.0",
    "pdf-lib": "^1.17.1",
    "node-qpdf2": "^4.1.0",
    "mammoth": "^1.6.0",
    "docx": "^8.5.0",
    "pdfjs-dist": "^3.11.174"
  },
  "engines": {
    "node": "18.x"
  }
}
```

**Note:** On Oracle with system FFmpeg installed, you may not need `@ffmpeg-installer/ffmpeg`. The handler code falls back to system `ffmpeg` if the npm package isn't found.

---

## 5. Recommended Oracle Architecture

### Option A: OCI Functions (Serverless) — Best for Cost
- **Service:** Oracle Functions (based on Fn Project)
- **Runtime:** Node.js 18 Docker container
- **Trigger:** OCI API Gateway (provides HTTPS endpoints with CORS)
- **Storage:** `/tmp` inside the container (ephemeral)
- **Timeout:** Up to 300 seconds (way better than Netlify's 26s)
- **Memory:** Up to 2GB per function

**Pros:** Pay-per-invocation, auto-scales to zero, no server to manage.  
**Cons:** Cold starts (~2-5s), Docker image must include FFmpeg + LibreOffice + qpdf (large image ~1.5GB).

### Option B: OCI Compute (Always-On VM) — Best for Performance
- **Service:** OCI Compute (VM.Standard.A1.Flex — ARM, Always Free tier: 4 OCPU + 24GB RAM)
- **Runtime:** Express.js server with the same function handlers
- **Reverse Proxy:** Nginx (SSL termination + body size limits)
- **Process Manager:** PM2 (auto-restart, clustering)

**Pros:** No cold starts, full control, generous free tier, easy to install system deps.  
**Cons:** Always running (but free tier covers this), manual scaling.

### Option C: OCI Container Instances — Middle Ground
- **Service:** OCI Container Instances
- **Runtime:** Docker container with all deps
- **Trigger:** OCI API Gateway or direct HTTPS

**Recommended: Option B** (Compute VM) for your use case because:
1. Free tier gives you 4 ARM cores + 24GB RAM permanently
2. FFmpeg video processing benefits from consistent CPU
3. LibreOffice requires filesystem state that works better on a VM
4. No cold starts = better UX
5. 500MB uploads need longer timeouts than serverless typically allows

---

## 6. Migration Implementation Plan

### Step 1: Provision Oracle Compute Instance
```
Shape: VM.Standard.A1.Flex (ARM)
OCPUs: 4
RAM: 24 GB
OS: Oracle Linux 9 or Ubuntu 22.04
Boot Volume: 50 GB
```

### Step 2: Install System Dependencies
```bash
# Oracle Linux 9
sudo dnf install -y epel-release
sudo dnf install -y ffmpeg nodejs npm libreoffice-headless qpdf git nginx certbot

# OR Ubuntu 22.04
sudo apt update && sudo apt install -y ffmpeg nodejs npm libreoffice-headless qpdf nginx certbot python3-certbot-nginx
```

### Step 3: Create Express.js Server

Replace the Netlify Functions format with a single Express.js app. The key change is wrapping each handler.

**File structure on Oracle:**
```
/srv/toolzspan-api/
├── package.json
├── server.js              ← Express entry point
├── functions/
│   ├── _lib/
│   │   └── handler.js    ← MODIFIED (remove Netlify response format)
│   ├── audio-compressor.js
│   ├── avi-to-mp4.js
│   ├── compress-mp3.js
│   ├── compress-mp4.js
│   ├── excel-to-pdf.js
│   ├── gif-converter.js
│   ├── gif-maker.js
│   ├── mov-to-mp4.js
│   ├── mp3-converter.js
│   ├── mp3-to-mp4.js
│   ├── mp4-converter.js
│   ├── mp4-to-mp3.js
│   ├── ogg-to-mp3.js
│   ├── pdf-to-word.js
│   ├── powerpoint-to-pdf.js
│   ├── remove-password-pdf.js
│   ├── video-compressor.js
│   ├── wav-to-mp3.js
│   ├── webm-to-mp4.js
│   └── word-to-pdf.js
└── ecosystem.config.js    ← PM2 config
```

### Step 4: Rewrite the Shared Handler (`_lib/handler.js`)

The current handler returns Netlify's proprietary response format (base64 body, statusCode, headers object). You must change it to use Express `res.send()` / `res.sendFile()` instead.

**Current Netlify format (MUST CHANGE):**
```js
// Returns { statusCode, headers, body, isBase64Encoded }
function binaryResponse(buffer, filename, mimeType) {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': mimeType,
      'Content-Disposition': `attachment; filename="${filename}"`,
      ...corsHeaders()
    },
    body: buffer.toString('base64'),
    isBase64Encoded: true
  };
}
```

**New Express format:**
```js
// Express middleware-style response
function sendBinary(res, buffer, filename, mimeType) {
  res.set({
    'Content-Type': mimeType,
    'Content-Disposition': `attachment; filename="${filename}"`,
    'Access-Control-Allow-Origin': '*'
  });
  res.send(buffer);
}

function sendError(res, statusCode, message) {
  res.status(statusCode).json({ error: message });
}
```

### Step 5: Create `server.js` (Express Entry Point)

```js
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.options('*', cors());

// Multer for multipart handling (500MB max)
const upload = multer({
  dest: '/tmp/toolzspan-uploads/',
  limits: { fileSize: 500 * 1024 * 1024 }
});

// Mount each function as a route
// Pattern: POST /api/<function-name>
const functions = [
  'audio-compressor', 'avi-to-mp4', 'compress-mp3', 'compress-mp4',
  'excel-to-pdf', 'gif-converter', 'gif-maker', 'mov-to-mp4',
  'mp3-converter', 'mp3-to-mp4', 'mp4-converter', 'mp4-to-mp3',
  'ogg-to-mp3', 'pdf-to-word', 'powerpoint-to-pdf',
  'remove-password-pdf', 'video-compressor', 'wav-to-mp3',
  'webm-to-mp4', 'word-to-pdf', 'add-password-pdf'
];

functions.forEach(name => {
  const handler = require(`./functions/${name}`);
  app.post(`/api/${name}`, upload.single('file'), handler);
});

app.listen(PORT, () => console.log(`Toolzspan API running on port ${PORT}`));
```

### Step 6: Adapt Each Function to Express Middleware Format

**Before (Netlify):**
```js
exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return preflight();
  // ...parse multipart from event.body...
  return binaryResponse(buffer, filename, mime);
};
```

**After (Express):**
```js
module.exports = async (req, res) => {
  try {
    const file = req.file; // multer already parsed
    const fields = req.body;
    // ... process file ...
    sendBinary(res, buffer, filename, mime);
  } catch (err) {
    sendError(res, 500, err.message);
  }
};
```

### Step 7: PM2 Configuration (`ecosystem.config.js`)

```js
module.exports = {
  apps: [{
    name: 'toolzspan-api',
    script: 'server.js',
    instances: 2,       // 2 of 4 cores for API
    exec_mode: 'cluster',
    max_memory_restart: '4G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
```

### Step 8: Nginx Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name api.toolzspan.site;

    ssl_certificate /etc/letsencrypt/live/api.toolzspan.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.toolzspan.site/privkey.pem;

    client_max_body_size 500M;
    proxy_read_timeout 300s;
    proxy_connect_timeout 10s;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name api.toolzspan.site;
    return 301 https://$host$request_uri;
}
```

### Step 9: DNS Setup
- Add A record: `api.toolzspan.site` → Oracle VM public IP
- Keep main site on Netlify (or move static files to OCI Object Storage + CDN)
- Run `certbot --nginx -d api.toolzspan.site` for SSL

---

## 7. Frontend Changes Required

### Only ONE file needs changing: `js/server-tool.js`

Change the endpoint URL pattern from:
```js
endpoint: '/.netlify/functions/excel-to-pdf'
```
To:
```js
endpoint: 'https://api.toolzspan.site/api/excel-to-pdf'
```

**Two approaches:**

#### Approach A: Change the client helper (recommended)
Modify `server-tool.js` line 99 to prepend the API base URL:

```js
// Add at top of the IIFE:
var API_BASE = 'https://api.toolzspan.site';

// Then in run():
var url = opts.endpoint.startsWith('http') ? opts.endpoint : API_BASE + '/api' + opts.endpoint.replace('/.netlify/functions', '');
var res = await fetch(url, { method: 'POST', body: form });
```

#### Approach B: Bulk find-replace in tool HTML files
Replace all occurrences of `/.netlify/functions/` with `https://api.toolzspan.site/api/` in the 21 tool HTML files.

**Approach A is better** because it's a single-file change and lets you toggle between environments.

### What does NOT change:
- The request format (multipart/form-data with `file` + optional fields) stays the same
- The response format (binary blob + Content-Disposition header) stays the same
- No tool HTML pages need structural changes
- `main.js`, `search.js` are unaffected

---

## 8. Security Considerations

1. **Rate Limiting:** Add `express-rate-limit` — suggest 10 requests/min per IP for video tools
2. **File Validation:** Already done in each handler (extension checks, size limits)
3. **Temp File Cleanup:** Already implemented via `cleanup()` helper — add a cron fallback:
   ```bash
   # Cron: clean orphaned tmp files older than 1 hour
   0 * * * * find /tmp/toolzspan-uploads -mmin +60 -delete
   ```
4. **Firewall:** OCI Security List — open only ports 80, 443, 22 (SSH)
5. **No secrets/API keys:** None of the functions use external API keys

---

## 9. Testing Checklist

After deployment, test each function:

| # | Tool | Test File | Expected Result |
|---|------|-----------|----------------|
| 1 | audio-compressor | 5MB mp3 | Smaller mp3 returned |
| 2 | avi-to-mp4 | 10MB avi | mp4 returned |
| 3 | compress-mp3 | 3MB mp3 | Smaller mp3 returned |
| 4 | compress-mp4 | 20MB mp4 | Smaller mp4 returned |
| 5 | excel-to-pdf | 1MB xlsx | pdf returned |
| 6 | gif-converter | 5MB gif | mp4 returned |
| 7 | gif-maker | 10MB mp4 | gif returned |
| 8 | mov-to-mp4 | 15MB mov | mp4 returned |
| 9 | mp3-converter | 3MB wav | mp3 returned |
| 10 | mp3-to-mp4 | 3MB mp3 | mp4 (w/ black video) |
| 11 | mp4-converter | 10MB webm | mp4 returned |
| 12 | mp4-to-mp3 | 10MB mp4 | mp3 returned |
| 13 | ogg-to-mp3 | 2MB ogg | mp3 returned |
| 14 | pdf-to-word | 1MB pdf | docx returned |
| 15 | powerpoint-to-pdf | 2MB pptx | pdf returned |
| 16 | remove-password-pdf | 1MB encrypted pdf + password | unlocked pdf |
| 17 | video-compressor | 30MB mp4 | Smaller mp4 |
| 18 | wav-to-mp3 | 10MB wav | mp3 returned |
| 19 | webm-to-mp4 | 5MB webm | mp4 returned |
| 20 | word-to-pdf | 1MB docx | pdf returned |
| 21 | add-password-pdf | 1MB pdf + password | encrypted pdf |

---

## 10. Rollback Plan

If Oracle has issues:
1. The static site can remain on Netlify unchanged
2. Revert `server-tool.js` to use `/.netlify/functions/` endpoints
3. Netlify functions still exist in the repo under `netlify/functions/`

---

## 11. Cost Comparison

| Resource | Netlify Pro | Oracle Cloud (Always Free) |
|----------|-------------|---------------------------|
| Compute | 26s timeout, 1024MB RAM | 300s+ timeout, 24GB RAM |
| Bandwidth | 1TB/month included | 10TB/month free |
| Functions | 125K invocations/month | Unlimited (VM) |
| Storage | 512MB ephemeral | 50GB+ boot volume |
| Price | ~$19/month | **$0** (Always Free tier) |

---

## 12. Complete Source Files Reference

All source code is in the repository at these paths:

### Backend (copy to Oracle):
- `netlify/functions/_lib/handler.js` — Shared utilities (MUST be rewritten for Express)
- `netlify/functions/*.js` — All 21 function handlers (MUST be adapted to Express)
- `package.json` — NPM dependencies

### Frontend (minimal change):
- `js/server-tool.js` — Client helper (change API_BASE URL)
- `tools/*.html` (21 files) — Tool pages that call ToolzspanServer.run()

### Config (for reference, not needed on Oracle):
- `netlify.toml` — Current Netlify config (redirects, headers, timeouts)

---

## 13. Full Existing Source Code

### `_lib/handler.js` (Shared Handler — REWRITE THIS)

```js
// Shared helpers for Toolzspan Netlify Functions
// - Multipart form parsing (busboy)
// - Temp file management
// - Standard error/success response shape
// - FFmpeg runner factory

const Busboy = require('busboy');
const fs = require('fs');
const path = require('path');
const os = require('os');
const crypto = require('crypto');
const { execFile } = require('child_process');
const { promisify } = require('util');
const execFileP = promisify(execFile);

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  };
}

function jsonError(statusCode, message) {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json', ...corsHeaders() },
    body: JSON.stringify({ error: message })
  };
}

function binaryResponse(buffer, filename, mimeType) {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': mimeType,
      'Content-Disposition': `attachment; filename="${filename}"`,
      ...corsHeaders()
    },
    body: buffer.toString('base64'),
    isBase64Encoded: true
  };
}

function preflight() {
  return { statusCode: 204, headers: corsHeaders(), body: '' };
}

function parseMultipart(event, opts = {}) {
  const maxBytes = opts.maxBytes || 50 * 1024 * 1024;
  return new Promise((resolve, reject) => {
    const contentType = event.headers['content-type'] || event.headers['Content-Type'];
    if (!contentType || !contentType.includes('multipart/form-data')) {
      return reject(new Error('Expected multipart/form-data'));
    }
    const bb = Busboy({ headers: { 'content-type': contentType }, limits: { fileSize: maxBytes, files: 1 } });
    const fields = {};
    let fileInfo = null;
    let fileTooLarge = false;

    bb.on('file', (name, stream, info) => {
      const tmpPath = path.join(os.tmpdir(), `${crypto.randomBytes(8).toString('hex')}-${info.filename}`);
      const out = fs.createWriteStream(tmpPath);
      let bytes = 0;
      stream.on('data', (chunk) => { bytes += chunk.length; });
      stream.on('limit', () => { fileTooLarge = true; });
      stream.pipe(out);
      out.on('close', () => {
        fileInfo = { name: info.filename, size: bytes, tmpPath, mimeType: info.mimeType };
      });
    });

    bb.on('field', (name, val) => { fields[name] = val; });
    bb.on('error', reject);
    bb.on('close', () => {
      if (fileTooLarge) return reject(new Error(`File exceeds maximum size of ${(maxBytes / 1024 / 1024).toFixed(0)}MB`));
      if (!fileInfo) return reject(new Error('No file uploaded'));
      resolve({ file: fileInfo, fields });
    });

    const body = event.isBase64Encoded ? Buffer.from(event.body, 'base64') : Buffer.from(event.body || '', 'binary');
    bb.end(body);
  });
}

function cleanup(...paths) {
  for (const p of paths) {
    if (!p) continue;
    try { fs.unlinkSync(p); } catch (_) {}
  }
}

let _ffmpegPath = null;
function getFfmpegPath() {
  if (_ffmpegPath) return _ffmpegPath;
  try {
    _ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
  } catch (e) {
    _ffmpegPath = 'ffmpeg';
  }
  return _ffmpegPath;
}

async function runFfmpeg(inputPath, outputExt, args) {
  const outPath = path.join(os.tmpdir(), `${crypto.randomBytes(8).toString('hex')}.${outputExt}`);
  const ffmpeg = getFfmpegPath();
  const fullArgs = ['-y', '-i', inputPath, ...args, outPath];
  try {
    await execFileP(ffmpeg, fullArgs, { maxBuffer: 1024 * 1024 * 100 });
    const buf = fs.readFileSync(outPath);
    cleanup(outPath);
    return buf;
  } catch (err) {
    cleanup(outPath);
    const stderr = (err.stderr || '').toString().split('\n').slice(-5).join('\n');
    throw new Error(`FFmpeg failed: ${stderr || err.message}`);
  }
}

function makeFfmpegHandler({ allowedExtensions, outputExt, outputMime, maxBytes, buildArgs, defaultOutName }) {
  return async (event) => {
    if (event.httpMethod === 'OPTIONS') return preflight();
    if (event.httpMethod !== 'POST') return jsonError(405, 'Method not allowed');

    let parsed;
    try {
      parsed = await parseMultipart(event, { maxBytes });
    } catch (err) {
      return jsonError(400, err.message);
    }

    const { file, fields } = parsed;

    if (allowedExtensions && allowedExtensions.length) {
      const ext = path.extname(file.name).toLowerCase().replace('.', '');
      if (!allowedExtensions.includes(ext)) {
        cleanup(file.tmpPath);
        return jsonError(400, `Unsupported input format: ${ext}. Allowed: ${allowedExtensions.join(', ')}`);
      }
    }

    const ext = (typeof outputExt === 'function') ? outputExt(fields, file) : outputExt;

    let outputBuffer;
    try {
      const args = buildArgs(file, fields, ext);
      outputBuffer = await runFfmpeg(file.tmpPath, ext, args);
    } catch (err) {
      cleanup(file.tmpPath);
      return jsonError(500, err.message);
    }

    cleanup(file.tmpPath);

    const baseName = path.parse(file.name).name;
    const outName = (defaultOutName ? defaultOutName(baseName, ext, fields) : `${baseName}.${ext}`);
    const mime = (typeof outputMime === 'function') ? outputMime(ext) : outputMime;

    return binaryResponse(outputBuffer, outName, mime);
  };
}

module.exports = {
  corsHeaders, jsonError, binaryResponse, preflight,
  parseMultipart, cleanup, getFfmpegPath, runFfmpeg, makeFfmpegHandler
};
```

### `server-tool.js` (Frontend Client — CHANGE API_BASE ONLY)

```js
/* TOOLZSPAN — Server-side tool client helper
   Posts a file + fields to the API server.
   Currently posts to: /.netlify/functions/<name>
   After Oracle migration, change to: https://api.toolzspan.site/api/<name>
*/
(function (global) {
  'use strict';

  // === CHANGE THIS LINE FOR ORACLE ===
  // var API_BASE = '';  // current (relative to Netlify)
  // var API_BASE = 'https://api.toolzspan.site';  // after Oracle migration

  async function run(opts) {
    // opts.endpoint is currently '/.netlify/functions/xxx'
    // After migration, transform: API_BASE + opts.endpoint.replace('/.netlify/functions', '/api')
    var form = new FormData();
    form.append('file', opts.file, opts.file.name);
    if (opts.fields) Object.keys(opts.fields).forEach(function (k) {
      if (opts.fields[k] !== undefined && opts.fields[k] !== null) form.append(k, opts.fields[k]);
    });
    var res = await fetch(opts.endpoint, { method: 'POST', body: form });
    // expects binary response with Content-Disposition header
    // ...
  }

  global.ToolzspanServer = { run: run, downloadBlob: downloadBlob, showError: showError, hideMessages: hideMessages };
})(window);
```

---

## 14. Step-by-Step Summary for the Implementing AI

1. **Provision** an OCI ARM VM (A1.Flex, 4 OCPU, 24GB RAM, Oracle Linux 9 or Ubuntu 22.04)
2. **Install** FFmpeg, LibreOffice (headless), qpdf, Node.js 18, Nginx, PM2, Certbot
3. **Create** `/srv/toolzspan-api/` directory structure
4. **Rewrite** `_lib/handler.js` to Express format (replace Netlify response objects with `res.send()/res.json()`, replace `parseMultipart` with multer middleware)
5. **Adapt** all 21 function files from `exports.handler = async (event) => {}` to `module.exports = async (req, res) => {}`
6. **Create** `server.js` with Express routing and multer middleware
7. **Create** PM2 `ecosystem.config.js`
8. **Configure** Nginx as reverse proxy with SSL (Let's Encrypt)
9. **Set up** DNS: `api.toolzspan.site` A record → VM public IP
10. **Open** OCI Security List ports 80, 443, 22
11. **Modify** `js/server-tool.js` on the frontend: add `API_BASE = 'https://api.toolzspan.site'` and rewrite the URL in the `run()` function
12. **Test** all 21 endpoints with sample files
13. **Deploy** frontend change (push to Netlify or wherever static site is hosted)

---

## 15. Oracle Always Free Tier Eligibility

The following resources qualify under Oracle's **Always Free** tier (no time limit):
- **Compute:** Up to 4 Ampere A1 cores + 24 GB RAM total (can be 1 VM or split)
- **Boot Volume:** 200 GB total
- **Object Storage:** 20 GB
- **Outbound Data:** 10 TB/month
- **Load Balancer:** 1 flexible LB (10 Mbps)

This is more than enough for Toolzspan's workload.

---

*Document generated from codebase analysis of `c:\GravityProject\toolzspan.site\` on May 13, 2026.*
