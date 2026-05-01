# Phase D3: Static audit of all 50 tool pages.
# Produces TOOL_AUDIT.md and prints a summary table.

$ErrorActionPreference = 'Stop'
$toolsDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools'
$report = Join-Path (Split-Path -Parent $PSScriptRoot) 'TOOL_AUDIT.md'

# Per-tool expectation map. Each entry: category, engine, expectedStatus
$expectations = @{
  # --- SERVER-SIDE (newly rewired in D1) ---
  'mp3-converter.html'       = @{ Cat='Audio';    Engine='Netlify FFmpeg'; Expected='Server' }
  'wav-to-mp3.html'          = @{ Cat='Audio';    Engine='Netlify FFmpeg'; Expected='Server' }
  'ogg-to-mp3.html'          = @{ Cat='Audio';    Engine='Netlify FFmpeg'; Expected='Server' }
  'compress-mp3.html'        = @{ Cat='Audio';    Engine='Netlify FFmpeg'; Expected='Server' }
  'mp4-to-mp3.html'          = @{ Cat='Audio';    Engine='Netlify FFmpeg'; Expected='Server' }
  'audio-compressor.html'    = @{ Cat='Audio';    Engine='Netlify FFmpeg'; Expected='Server' }
  'mp3-to-mp4.html'          = @{ Cat='Video';    Engine='Netlify FFmpeg'; Expected='Server' }
  'mp4-converter.html'       = @{ Cat='Video';    Engine='Netlify FFmpeg'; Expected='Server' }
  'avi-to-mp4.html'          = @{ Cat='Video';    Engine='Netlify FFmpeg'; Expected='Server' }
  'mov-to-mp4.html'          = @{ Cat='Video';    Engine='Netlify FFmpeg'; Expected='Server' }
  'webm-to-mp4.html'         = @{ Cat='Video';    Engine='Netlify FFmpeg'; Expected='Server' }
  'video-compressor.html'    = @{ Cat='Video';    Engine='Netlify FFmpeg'; Expected='Server' }
  'compress-mp4.html'        = @{ Cat='Video';    Engine='Netlify FFmpeg'; Expected='Server' }
  'gif-maker.html'           = @{ Cat='GIF';      Engine='Netlify FFmpeg'; Expected='Server' }
  'gif-converter.html'       = @{ Cat='GIF';      Engine='Netlify FFmpeg'; Expected='Server' }
  'word-to-pdf.html'         = @{ Cat='Office';   Engine='Netlify LibreOffice'; Expected='Server+Binary' }
  'excel-to-pdf.html'        = @{ Cat='Office';   Engine='Netlify LibreOffice'; Expected='Server+Binary' }
  'powerpoint-to-pdf.html'   = @{ Cat='Office';   Engine='Netlify LibreOffice'; Expected='Server+Binary' }
  'pdf-to-word.html'         = @{ Cat='PDF';      Engine='Netlify pdfjs+docx'; Expected='Server' }
  'add-password-pdf.html'    = @{ Cat='PDF';      Engine='Netlify qpdf';       Expected='Server+Binary' }
  'remove-password-pdf.html' = @{ Cat='PDF';      Engine='Netlify qpdf';       Expected='Server+Binary' }

  # --- CLIENT-SIDE (still browser-based) ---
  'pdf-compressor.html'      = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'pdf-merger.html'          = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'pdf-splitter.html'        = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'pdf-page-rotator.html'    = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'pdf-page-remover.html'    = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'pdf-editor.html'          = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'add-watermark-pdf.html'   = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'sign-pdf.html'            = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'pdf-to-image.html'        = @{ Cat='PDF';      Engine='pdfjs';              Expected='Client' }
  'image-to-pdf.html'        = @{ Cat='PDF';      Engine='pdf-lib';            Expected='Client' }
  'ocr-pdf.html'             = @{ Cat='PDF';      Engine='pdfjs+tesseract';    Expected='Client' }
  'scan-image.html'          = @{ Cat='PDF';      Engine='tesseract';          Expected='Client' }
  'image-compressor.html'    = @{ Cat='Image';    Engine='Canvas';             Expected='Client' }
  'image-resizer.html'       = @{ Cat='Image';    Engine='Canvas';             Expected='Client' }
  'jpg-to-png.html'          = @{ Cat='Image';    Engine='Canvas';             Expected='Client' }
  'png-to-jpg.html'          = @{ Cat='Image';    Engine='Canvas';             Expected='Client' }
  'jpg-to-webp.html'         = @{ Cat='Image';    Engine='Canvas';             Expected='Client' }
  'png-to-webp.html'         = @{ Cat='Image';    Engine='Canvas';             Expected='Client' }
  'webp-to-jpg.html'         = @{ Cat='Image';    Engine='Canvas';             Expected='Client' }
  'webp-to-png.html'         = @{ Cat='Image';    Engine='Canvas';             Expected='Client' }
  'heic-to-jpg.html'         = @{ Cat='Image';    Engine='heic2any';           Expected='Client' }
  'gif-compressor.html'      = @{ Cat='GIF';      Engine='Canvas';             Expected='Client' }
  'qr-code-generator.html'   = @{ Cat='General';  Engine='qrious';             Expected='Client' }
  'word-counter.html'        = @{ Cat='General';  Engine='Native JS';          Expected='Client' }
  'color-picker.html'        = @{ Cat='General';  Engine='Canvas';             Expected='Client' }
  'units-converter.html'     = @{ Cat='General';  Engine='Native JS';          Expected='Client' }
  'time-converter.html'      = @{ Cat='General';  Engine='Native JS';          Expected='Client' }
  'trim-audio.html'          = @{ Cat='Audio';    Engine='Web Audio API';      Expected='Client' }
  'all-tools.html'           = @{ Cat='Directory'; Engine='N/A';               Expected='Directory' }
}

$rows = @()

Get-ChildItem -Path $toolsDir -Filter '*.html' | Sort-Object Name | ForEach-Object {
  $name = $_.Name
  $content = Get-Content $_.FullName -Raw
  $exp = $expectations[$name]
  if (-not $exp) {
    $rows += [PSCustomObject]@{
      File=$name; Cat='?'; Engine='?'; Status='[WARN]'; Notes='Not in expectations map'
    }
    return
  }

  $status = '[OK]'
  $notes = @()

  # --- Shared header integrity checks (apply to all tool pages) ---
  if (-not ($content -match 'id="menuToggle"')) { $status = '[FAIL]'; $notes += 'missing menuToggle' }
  if (-not ($content -match 'id="navMenu"'))    { $status = '[FAIL]'; $notes += 'missing navMenu' }
  if (-not ($content -match 'main\.js'))         { $status = '[FAIL]'; $notes += 'missing main.js' }
  if ($content -match "getElementById\(['""]menuToggle['""]\).addEventListener") {
    $status = '[FAIL]'; $notes += 'conflicting inline menuToggle script'
  }

  # --- AdSense retrofit (except all-tools.html) ---
  if ($name -ne 'all-tools.html') {
    $top = ([regex]::Matches($content, 'adsense-top')).Count
    $mid = ([regex]::Matches($content, 'adsense-mid')).Count
    $bot = ([regex]::Matches($content, 'adsense-bottom')).Count
    if ($top -ne 1) { $status = '[WARN]'; $notes += "top=$top" }
    if ($mid -ne 1) { $status = '[WARN]'; $notes += "mid=$mid" }
    if ($bot -ne 1) { $status = '[WARN]'; $notes += "bot=$bot" }
  }

  # --- Engine-specific checks ---
  switch ($exp.Expected) {
    'Server' {
      if (-not ($content -match '/\.netlify/functions/')) {
        $status = '[FAIL]'; $notes += 'not calling Netlify function'
      }
      if (-not ($content -match 'server-tool\.js')) {
        $status = '[FAIL]'; $notes += 'missing server-tool.js'
      }
    }
    'Server+Binary' {
      if (-not ($content -match '/\.netlify/functions/')) {
        $status = '[FAIL]'; $notes += 'not calling Netlify function'
      }
      if (-not ($content -match 'server-tool\.js')) {
        $status = '[FAIL]'; $notes += 'missing server-tool.js'
      }
      $notes += 'requires LibreOffice or qpdf on Netlify image'
    }
    'Client' {
      # Look for evidence of a processing lib or inline JS tied to a convert button OR live-update
      $hasLib = ($content -match 'pdf-lib|pdfjs|tesseract|qrious|heic2any|mammoth|jszip')
      $hasHandler = ($content -match "addEventListener\(['""](click|input|change|keyup|submit)['""]")
      if (-not $hasHandler) { $status = '[WARN]'; $notes += 'no interaction handler found' }
      switch -Regex ($exp.Engine) {
        'pdf-lib'     { if (-not ($content -match 'pdf-lib')) { $status = '[WARN]'; $notes += 'pdf-lib not loaded' } }
        'pdfjs'       { if (-not ($content -match 'pdfjs')) { $status = '[WARN]'; $notes += 'pdfjs not loaded' } }
        'tesseract'   { if (-not ($content -match 'tesseract')) { $status = '[WARN]'; $notes += 'tesseract not loaded' } }
        'qrious'      { if (-not ($content -match 'qrious')) { $status = '[WARN]'; $notes += 'qrious not loaded' } }
        'heic2any'    { if (-not ($content -match 'heic2any|heic')) { $status = '[WARN]'; $notes += 'heic2any not loaded' } }
      }
    }
    'Directory' {
      # all-tools.html - just a directory page, no processing needed
    }
  }

  # --- Check for lingering stale client-lib references on server-side pages ---
  if ($exp.Expected -eq 'Server' -or $exp.Expected -eq 'Server+Binary') {
    if ($content -match 'FFmpeg\.createFFmpeg|@ffmpeg/ffmpeg@') {
      $status = '[WARN]'; $notes += 'stale FFmpeg.wasm CDN ref'
    }
    if ($content -match 'pdf-lib@\d') {
      $status = '[WARN]'; $notes += 'stale pdf-lib CDN ref'
    }
  }

  $rows += [PSCustomObject]@{
    File=$name; Cat=$exp.Cat; Engine=$exp.Engine; Status=$status; Notes=($notes -join '; ')
  }
}

# --- Print summary ---
$total = $rows.Count
$ok    = ($rows | Where-Object { $_.Status -eq '[OK]'   }).Count
$warn  = ($rows | Where-Object { $_.Status -eq '[WARN]' }).Count
$fail  = ($rows | Where-Object { $_.Status -eq '[FAIL]' }).Count

Write-Host ""
Write-Host "Total: $total | OK: $ok | WARN: $warn | FAIL: $fail"
Write-Host ""

# --- Write markdown report ---
$md = @()
$md += '# Toolzspan Tool Audit (Phase D3)'
$md += ''
$md += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$md += ''
$md += "**Summary:** $total pages audited, $ok OK, $warn warnings, $fail failures."
$md += ''
$md += '## Status legend'
$md += ''
$md += '- **OK** - all checks passed; tool is expected to work as designed.'
$md += '- **WARN** - minor issue (e.g. missing ad placement, stale meta copy) that does not block functionality.'
$md += '- **FAIL** - blocking issue; user interaction will break.'
$md += ''
$md += '## Results table'
$md += ''
$md += '| Status | File | Category | Engine | Notes |'
$md += '|:------:|:-----|:--------:|:-------|:------|'
foreach ($row in $rows) {
  $n = if ($row.Notes) { $row.Notes } else { '-' }
  $md += "| $($row.Status) | ``$($row.File)`` | $($row.Cat) | $($row.Engine) | $n |"
}
$md += ''
$md += '## Categorisation'
$md += ''
$md += '- **Server (Netlify FFmpeg)** - 15 tools. Work once `npm install` completes and functions deploy.'
$md += '- **Server + Binary** - 5 tools (3 Office + 2 PDF password). Require LibreOffice or qpdf on the Netlify image; see `DEPLOY.md` section 3.'
$md += '- **Client-side** - 28 tools. Run entirely in the browser; no server dependency.'
$md += '- **Directory** - 1 page (`all-tools.html`).'
$md += ''
$md += '## Known follow-ups'
$md += ''
$md += "- Stale meta copy mentioning *browser-based* or *FFmpeg.wasm* on a few rewired pages is cosmetic and does not affect function. Fix during the v9.1 Section 13 polish pass."
$md += "- ``pdf-to-word`` uses a JS-only path (pdfjs + docx). Layout fidelity is lower than the original v9.1 Python ``pdf2docx`` recommendation. Swap to a Python function if fidelity becomes a blocker."
$md += "- Deploying with no extra setup will make the 5 **Server + Binary** tools return HTTP 503 until LibreOffice / qpdf are installed on the function image."

$md -join "`r`n" | Set-Content -LiteralPath $report -Encoding UTF8
Write-Host "Report written: $report"
Write-Host ""

# --- Print table ---
$rows | Format-Table -AutoSize
