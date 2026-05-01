# Phase B4: Convert related-posts <ul><li><a> lists to .related-posts-grid + .related-post-card layout
# Applies to all newer blogs EXCEPT Trim Audio (already has cards)

$ErrorActionPreference = 'Stop'
$blogDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'blog'

# Topical, non-salesy descriptions for each blog (for card <p>)
$descMap = @{
  'post-01.html' = 'Reduce PDF size while keeping text and images sharp.'
  'post-02.html' = 'Curated free PDF tools to compress, merge, split, convert, and edit.'
  'post-03.html' = 'Combine multiple PDFs into a single file in your browser.'
  'post-04.html' = 'Extract specific pages or split a PDF into individual files.'
  'post-05.html' = 'Turn PDF pages into JPG or PNG images at custom resolutions.'
  'post-06.html' = 'Combine photos, scans, or screenshots into one PDF.'
  'post-07.html' = 'Add password protection to sensitive PDF documents before sharing.'
  'post-08.html' = 'Unlock a password-protected PDF when you know the original password.'
  'post-09.html' = 'Mark PDF documents as confidential, draft, or branded with text.'
  'post-10.html' = 'Add your handwritten signature to a PDF without printing it.'
  'post-11.html' = 'How OCR turns scanned PDFs into searchable, editable text.'
  'post-12.html' = 'Extract text from photos of documents, receipts, or notes.'
  'post-13.html' = 'Turn .doc and .docx files into universally readable PDFs.'
  'post-14.html' = 'Edit a PDF in Word while preserving formatting and layout.'
  'post-15.html' = 'Share PowerPoint decks as PDF files that look the same on every device.'
  'post-16.html' = 'Turn Excel spreadsheets into clean, shareable PDF documents.'
  'post-17.html' = 'Fix sideways or upside-down pages in your PDF without software.'
  'post-18.html' = 'Delete unwanted pages from PDFs in seconds with no install.'
  'post-19.html' = 'Practical strategies to shrink oversized PDFs for email and web upload.'
  'post-20.html' = 'When to compress vs optimize a PDF and the differences between them.'
  'post-21.html' = 'Smaller image files for faster page loads without losing quality.'
  'post-22.html' = 'Generate QR codes for URLs, text, contact info, and more.'
  'best-free-online-unit-converters-2026.html' = 'Convert length, weight, temperature, and more in your browser.'
  'best-free-online-video-compressors-2026.html' = 'Browser-based video compressors that need no sign-up or install.'
  'how-to-compress-gif-file-online.html' = 'Shrink GIF size without sacrificing animation smoothness.'
  'how-to-compress-video-without-losing-quality.html' = 'Free methods, codec tips, and step-by-step compression instructions.'
  'how-to-convert-avi-to-mp4-online-free.html' = 'Open older AVI files on iPhone, Android, and modern devices.'
  'how-to-convert-heic-to-jpg-online-free.html' = 'Open iPhone photos on Windows, Android, or any device.'
  'how-to-convert-jpg-to-png-online-free.html' = 'Preserve transparency and quality when switching image formats.'
  'how-to-convert-jpg-to-webp-online-free.html' = 'Get smaller image files for faster website load times.'
  'how-to-convert-mov-to-mp4-online-free.html' = 'Make iPhone videos play on every platform without re-encoding loss.'
  'how-to-convert-mp4-to-mp3-online-free.html' = 'Extract audio from any video file in seconds.'
  'how-to-convert-png-to-jpg-online-free.html' = 'Reduce image file size while keeping visual quality high.'
  'how-to-convert-png-to-webp-online-free.html' = 'Optimize PNGs for web delivery with much smaller file sizes.'
  'how-to-convert-time-zones-online-free.html' = 'Find the current time in any city and avoid scheduling errors.'
  'how-to-make-gif-from-video-online-free.html' = 'Turn short video clips into looping animated GIFs.'
  'how-to-trim-audio-online-free.html' = 'Cut audio with a visual waveform editor right in your browser.'
  'mp3-vs-mp4-difference-and-how-to-convert.html' = 'Understand audio vs video formats and how to switch between them.'
  'webp-to-jpg-convert-webp-images-online-free.html' = 'Open WEBP images on devices that lack native support.'
  'webp-to-png-convert-webp-to-png-online-free.html' = 'Get lossless PNG output that supports transparency.'
}

# Build title lookup (strip " | Toolzspan Blog" suffix)
$titleMap = @{}
Get-ChildItem -Path $blogDir -Filter '*.html' | Where-Object { $_.Name -ne 'index.html' } | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  if ($c -match '<title>([^<]+)</title>') {
    $titleMap[$_.Name] = ($matches[1] -replace ' \| Toolzspan Blog$', '')
  }
}

# Files to convert: all newer blogs except Trim Audio
$skip = @('how-to-trim-audio-online-free.html', 'index.html')
$targets = $descMap.Keys | Where-Object { $_ -notlike 'post-*.html' -and $skip -notcontains $_ }

$updated = 0
foreach ($file in ($targets | Sort-Object)) {
  $path = Join-Path $blogDir $file
  if (-not (Test-Path $path)) { continue }
  $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $original = $content

  # Match the existing related-posts <div> block (single-line format from current files)
  $blockMatch = [regex]::Match($content, '<div class="related-posts">.*?</div>', 'Singleline')
  if (-not $blockMatch.Success) { continue }
  $oldBlock = $blockMatch.Value

  # Extract URLs from the old block
  $linkMatches = [regex]::Matches($oldBlock, '<a href="([^"]+)">([^<]+)</a>')
  if ($linkMatches.Count -eq 0) { continue }

  $cards = @()
  foreach ($lm in $linkMatches) {
    $href = $lm.Groups[1].Value
    # Normalize href - strip /blog/ prefix for lookup
    $key = $href -replace '^/blog/', '' -replace '^blog/', ''
    $title = if ($titleMap.ContainsKey($key)) { $titleMap[$key] } else { $lm.Groups[2].Value }
    $desc = if ($descMap.ContainsKey($key)) { $descMap[$key] } else { 'Related guide on Toolzspan.' }
    # Use relative href (matches Trim Audio convention)
    $relHref = $key
    $cards += "          <a href=`"$relHref`" class=`"related-post-card`"><h4>$title</h4><p>$desc</p></a>"
  }

  $newBlock = "<div class=`"related-posts`">`r`n        <h3>Related Posts</h3>`r`n        <div class=`"related-posts-grid`">`r`n" + ($cards -join "`r`n") + "`r`n        </div>`r`n      </div>"

  $content = $content.Replace($oldBlock, $newBlock)

  if ($content -ne $original) {
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
    $updated++
  }
}

Write-Host "Updated: $updated files"
