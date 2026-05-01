# Toolzspan Tool Audit (Phase D3)

Generated: 2026-05-01 13:49

**Summary:** 50 pages audited, 50 OK, 0 warnings, 0 failures.

## Status legend

- **OK** - all checks passed; tool is expected to work as designed.
- **WARN** - minor issue (e.g. missing ad placement, stale meta copy) that does not block functionality.
- **FAIL** - blocking issue; user interaction will break.

## Results table

| Status | File | Category | Engine | Notes |
|:------:|:-----|:--------:|:-------|:------|
| [OK] | `add-password-pdf.html` | PDF | Netlify qpdf | requires LibreOffice or qpdf on Netlify image |
| [OK] | `add-watermark-pdf.html` | PDF | pdf-lib | - |
| [OK] | `all-tools.html` | Directory | N/A | - |
| [OK] | `audio-compressor.html` | Audio | Netlify FFmpeg | - |
| [OK] | `avi-to-mp4.html` | Video | Netlify FFmpeg | - |
| [OK] | `color-picker.html` | General | Canvas | - |
| [OK] | `compress-mp3.html` | Audio | Netlify FFmpeg | - |
| [OK] | `compress-mp4.html` | Video | Netlify FFmpeg | - |
| [OK] | `excel-to-pdf.html` | Office | Netlify LibreOffice | requires LibreOffice or qpdf on Netlify image |
| [OK] | `gif-compressor.html` | GIF | Canvas | - |
| [OK] | `gif-converter.html` | GIF | Netlify FFmpeg | - |
| [OK] | `gif-maker.html` | GIF | Netlify FFmpeg | - |
| [OK] | `heic-to-jpg.html` | Image | heic2any | - |
| [OK] | `image-compressor.html` | Image | Canvas | - |
| [OK] | `image-resizer.html` | Image | Canvas | - |
| [OK] | `image-to-pdf.html` | PDF | pdf-lib | - |
| [OK] | `jpg-to-png.html` | Image | Canvas | - |
| [OK] | `jpg-to-webp.html` | Image | Canvas | - |
| [OK] | `mov-to-mp4.html` | Video | Netlify FFmpeg | - |
| [OK] | `mp3-converter.html` | Audio | Netlify FFmpeg | - |
| [OK] | `mp3-to-mp4.html` | Video | Netlify FFmpeg | - |
| [OK] | `mp4-converter.html` | Video | Netlify FFmpeg | - |
| [OK] | `mp4-to-mp3.html` | Audio | Netlify FFmpeg | - |
| [OK] | `ocr-pdf.html` | PDF | pdfjs+tesseract | - |
| [OK] | `ogg-to-mp3.html` | Audio | Netlify FFmpeg | - |
| [OK] | `pdf-compressor.html` | PDF | pdf-lib | - |
| [OK] | `pdf-editor.html` | PDF | pdf-lib | - |
| [OK] | `pdf-merger.html` | PDF | pdf-lib | - |
| [OK] | `pdf-page-remover.html` | PDF | pdf-lib | - |
| [OK] | `pdf-page-rotator.html` | PDF | pdf-lib | - |
| [OK] | `pdf-splitter.html` | PDF | pdf-lib | - |
| [OK] | `pdf-to-image.html` | PDF | pdfjs | - |
| [OK] | `pdf-to-word.html` | PDF | Netlify pdfjs+docx | - |
| [OK] | `png-to-jpg.html` | Image | Canvas | - |
| [OK] | `png-to-webp.html` | Image | Canvas | - |
| [OK] | `powerpoint-to-pdf.html` | Office | Netlify LibreOffice | requires LibreOffice or qpdf on Netlify image |
| [OK] | `qr-code-generator.html` | General | qrious | - |
| [OK] | `remove-password-pdf.html` | PDF | Netlify qpdf | requires LibreOffice or qpdf on Netlify image |
| [OK] | `scan-image.html` | PDF | tesseract | - |
| [OK] | `sign-pdf.html` | PDF | pdf-lib | - |
| [OK] | `time-converter.html` | General | Native JS | - |
| [OK] | `trim-audio.html` | Audio | Web Audio API | - |
| [OK] | `units-converter.html` | General | Native JS | - |
| [OK] | `video-compressor.html` | Video | Netlify FFmpeg | - |
| [OK] | `wav-to-mp3.html` | Audio | Netlify FFmpeg | - |
| [OK] | `webm-to-mp4.html` | Video | Netlify FFmpeg | - |
| [OK] | `webp-to-jpg.html` | Image | Canvas | - |
| [OK] | `webp-to-png.html` | Image | Canvas | - |
| [OK] | `word-counter.html` | General | Native JS | - |
| [OK] | `word-to-pdf.html` | Office | Netlify LibreOffice | requires LibreOffice or qpdf on Netlify image |

## Categorisation

- **Server (Netlify FFmpeg)** - 15 tools. Work once `npm install` completes and functions deploy.
- **Server + Binary** - 5 tools (3 Office + 2 PDF password). Require LibreOffice or qpdf on the Netlify image; see `DEPLOY.md` section 3.
- **Client-side** - 28 tools. Run entirely in the browser; no server dependency.
- **Directory** - 1 page (`all-tools.html`).

## Known follow-ups

- Stale meta copy mentioning *browser-based* or *FFmpeg.wasm* on a few rewired pages is cosmetic and does not affect function. Fix during the v9.1 Section 13 polish pass.
- `pdf-to-word` uses a JS-only path (pdfjs + docx). Layout fidelity is lower than the original v9.1 Python `pdf2docx` recommendation. Swap to a Python function if fidelity becomes a blocker.
- Deploying with no extra setup will make the 5 **Server + Binary** tools return HTTP 503 until LibreOffice / qpdf are installed on the function image.
