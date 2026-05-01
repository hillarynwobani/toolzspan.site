# Toolzspan — Netlify Deployment Notes

Generated as part of the v9.1 overhaul. This file documents what needs to be in place
for the newly server-side tools to run correctly.

## 1. First-time setup

From the project root:

```bash
npm install
```

This installs:

- `@ffmpeg-installer/ffmpeg` + `fluent-ffmpeg` — bundled FFmpeg binary for Node
- `busboy` — multipart parser
- `libreoffice-convert` — wrapper that invokes LibreOffice for Office→PDF
- `node-qpdf2` — wrapper that invokes qpdf for PDF password add/remove
- `pdf-lib`, `pdfjs-dist`, `mammoth`, `docx` — JS helpers for PDF parsing/generation

## 2. Netlify deploy

```bash
# Login once per machine
npx netlify login

# First-time link to the Netlify site
npx netlify link

# Deploy to production
npx netlify deploy --prod
```

Netlify auto-discovers `netlify/functions/*.js` and bundles each with esbuild
(config in `netlify.toml`).

## 3. Binary dependencies per function

All 21 Netlify functions live under `netlify/functions/`. Each lists what it needs.

### Out-of-the-box (no extra setup)

- **FFmpeg-based (16):** mp3-converter, wav-to-mp3, ogg-to-mp3, compress-mp3,
  mp4-to-mp3, audio-compressor, mp3-to-mp4, mp4-converter, avi-to-mp4,
  mov-to-mp4, webm-to-mp4, video-compressor, compress-mp4, gif-maker,
  gif-converter

  FFmpeg ships via `@ffmpeg-installer/ffmpeg` and is available inside the
  bundled function.

- **JS-only PDF (1):** pdf-to-word (uses `pdfjs-dist` + `docx` to produce a
  simple Word document from extracted text).

### Needs LibreOffice on the function's OS image

- **word-to-pdf, excel-to-pdf, powerpoint-to-pdf**

  `libreoffice-convert` shells out to the system `soffice` / `libreoffice`
  binary. Netlify's default Node runtime does **not** ship LibreOffice. Options:

  1. **Netlify Build plugin** — add a build-time install step (e.g. `apt-get
     install -y libreoffice`) for users on a plan that allows it.
  2. **Lambda layer** — upload a pre-built LibreOffice layer and attach it
     to these three functions.
  3. **VPS migration** — run these three specific functions on a small VPS
     (as suggested in v9.1 Section 4C-2) and point the client fetch at that
     host instead of `/.netlify/functions/`.

  Without LibreOffice installed, the functions return HTTP 503 with a clear
  error so the client can display it.

### Needs qpdf on the function's OS image

- **add-password-pdf, remove-password-pdf**

  Same pattern as LibreOffice: install `qpdf` package via the build image or
  a layer. Without it, the function returns 503.

## 4. Free-tier limits to be aware of

Per v9.1 Section 4C-2 — **do not hide these from users**:

- Function timeout: **10s free / 26s Pro** (set to 26 in `netlify.toml`).
- Function response size: **6 MB** (matters for video output — warn users).
- Function memory: 1 GB (tight for large LibreOffice jobs).
- Ephemeral `/tmp`: 512 MB.

The client helper `js/server-tool.js` surfaces a 502/504 as
*"Processing took too long. Please try a smaller file..."* automatically.

## 5. What was rewired on the client

All 21 server-side tool pages now use `/.netlify/functions/<name>` via the
shared helper `js/server-tool.js`. Each page:

1. Reads the local file.
2. POSTs multipart form data to its function.
3. Shows a spinner + *"Processing your file..."* message.
4. Downloads the returned binary as a file.

Previously these pages ran FFmpeg.wasm / pdf-lib / mammoth / jszip in the
browser. Those CDN script tags have been removed; only `main.js`, `search.js`,
and `server-tool.js` remain.

## 6. Re-running the rewire scripts

If you change a function's endpoint or field shape, regenerate the client
glue:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/rewire-server-tools.ps1
powershell -ExecutionPolicy Bypass -File scripts/rewire-pdf-tools.ps1
```

Both scripts are idempotent — they rewrite the trailing `<script>` block of
each tool page.

## 7. Smoke-testing before deploy

```bash
# Start Netlify dev with functions
npx netlify dev
```

Then visit `http://localhost:8888/tools/mp3-converter.html` and try a 1-2 MB
WAV/MP3 conversion. The FFmpeg-based pipeline should complete well within
10 seconds.
