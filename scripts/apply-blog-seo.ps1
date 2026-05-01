# Phase B2/B3 - Apply blog SEO metadata rewrites (40 blog files)
# Updates: <title>, <meta description>, og:title, og:description, twitter:title, twitter:description, JSON-LD Article schema
# Year-free titles ending with " | Toolzspan Blog", 50-60 chars; metas 150-160 chars

$ErrorActionPreference = 'Stop'
$blogDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'blog'

# Define mapping: file => @{ Title = '...'; Meta = '...' }
$map = @{
  'post-01.html' = @{ Title = 'How to Compress a PDF Without Quality Loss | Toolzspan Blog'; Meta = 'Learn how to compress a PDF without losing quality. Step-by-step guide to reduce PDF file size while keeping text sharp and images readable on any device.' }
  'post-02.html' = @{ Title = 'Best Free PDF Tools You Can Use Right Now | Toolzspan Blog'; Meta = 'A curated list of the best free online PDF tools you can use today. Compress, merge, split, convert, and edit PDFs without creating an account or paying.' }
  'post-03.html' = @{ Title = 'How to Merge Multiple PDFs Into One File | Toolzspan Blog'; Meta = 'Learn how to merge multiple PDF documents into one file for free. Step-by-step guide to combining PDFs directly in your browser with no software needed.' }
  'post-04.html' = @{ Title = 'How to Split a PDF Into Separate Pages | Toolzspan Blog'; Meta = 'Learn how to split a PDF into separate pages for free. Extract specific pages or break a document into individual files with a step-by-step browser guide.' }
  'post-05.html' = @{ Title = 'How to Convert PDF to JPG or PNG for Free | Toolzspan Blog'; Meta = 'Convert PDF to JPG or PNG image files for free in your browser. Step-by-step guide covers DPI choice, format trade-offs, and batch conversion of PDF pages.' }
  'post-06.html' = @{ Title = 'How to Convert Images Into a PDF File | Toolzspan Blog'; Meta = 'Convert images into a PDF file for free. Combine photos, scans, or screenshots into a single document with a step-by-step browser guide and practical tips.' }
  'post-07.html' = @{ Title = 'How to Add a Password to a PDF to Secure It | Toolzspan Blog'; Meta = 'Add a password to a PDF to secure sensitive documents before sharing. Step-by-step guide to PDF encryption with practical tips on choosing strong passwords.' }
  'post-08.html' = @{ Title = 'How to Remove a Password From a PDF File | Toolzspan Blog'; Meta = 'Remove a password from a PDF file for free when you know the original password. Step-by-step guide to unlocking PDF protection so you can edit or share it.' }
  'post-09.html' = @{ Title = 'How to Add a Watermark to a PDF for Free | Toolzspan Blog'; Meta = 'Add a custom text watermark to a PDF for free. Step-by-step guide to marking documents as confidential, draft, or branded across every page in your file.' }
  'post-10.html' = @{ Title = 'How to Sign a PDF Without Printing It | Toolzspan Blog'; Meta = 'Sign a PDF without printing it. Add your handwritten signature digitally using a free browser tool, save it for reuse, and send signed documents in minutes.' }
  'post-11.html' = @{ Title = 'What Is OCR and How Does It Work on PDFs? | Toolzspan Blog'; Meta = 'Understand OCR (Optical Character Recognition) and how it turns scanned PDFs into searchable, editable text. A beginner-friendly guide with practical tips.' }
  'post-12.html' = @{ Title = 'Convert a Scanned Image Into Editable Text | Toolzspan Blog'; Meta = 'Convert a scanned image into editable text using free OCR. Extract words from photos of documents, receipts, or handwritten notes in your browser quickly.' }
  'post-13.html' = @{ Title = 'Convert Word Documents to PDF for Free | Toolzspan Blog'; Meta = 'Convert Word documents to PDF for free. Turn .doc and .docx files into universally readable PDFs that look identical on every device, with no software install.' }
  'post-14.html' = @{ Title = 'Convert PDF to Word and Keep the Formatting | Toolzspan Blog'; Meta = 'Convert PDF back to Word while preserving formatting, fonts, and layout. Step-by-step guide to editing PDFs in Microsoft Word using free conversion tools.' }
  'post-15.html' = @{ Title = 'Convert PowerPoint Presentations to PDF | Toolzspan Blog'; Meta = 'Convert PowerPoint presentations to PDF for free. Share decks that look identical on every device with a step-by-step browser guide and practical tips.' }
  'post-16.html' = @{ Title = 'Convert Excel Spreadsheets to PDF for Free | Toolzspan Blog'; Meta = 'Convert Excel spreadsheets to PDF for free. Turn .xlsx and .xls files into clean, shareable PDFs with proper formatting, no broken column widths, and ease.' }
  'post-17.html' = @{ Title = 'How to Rotate Pages in a PDF File for Free | Toolzspan Blog'; Meta = 'Rotate pages in a PDF file for free. Fix sideways or upside-down pages without installing software using a quick step-by-step browser tool guide and tips.' }
  'post-18.html' = @{ Title = 'Remove Pages From a PDF Without Software | Toolzspan Blog'; Meta = 'Remove pages from a PDF without any software. Delete unwanted pages from your documents in seconds using a free browser tool with no sign-up or downloads.' }
  'post-19.html' = @{ Title = 'PDF File Too Large? Here Is How to Fix It | Toolzspan Blog'; Meta = 'PDF file too large? Practical tips, strategies, and free tools to shrink oversized PDFs for email attachments, web upload limits, and faster file sharing.' }
  'post-20.html' = @{ Title = 'PDF Compression vs Optimization Explained | Toolzspan Blog'; Meta = 'PDF compression vs optimization explained. Learn the key differences, when to compress, when to optimize, and how to choose the right approach for any PDF.' }
  'post-21.html' = @{ Title = 'How to Compress Images for the Web | Toolzspan Blog'; Meta = 'Compress images for the web without losing quality. Reduce file sizes for faster page loads, lower bandwidth, and better mobile performance using free tools.' }
  'post-22.html' = @{ Title = 'How to Generate QR Codes for Free | Toolzspan Blog'; Meta = 'Generate QR codes for free for URLs, text, and contact info. Learn where and how to use QR codes for business, marketing, restaurants, and personal projects.' }
  'best-free-online-unit-converters-2026.html' = @{ Title = 'Best Free Online Unit Converters Compared | Toolzspan Blog'; Meta = 'Find the best free online unit converters. Convert length, weight, temperature, volume, area, and speed instantly with no sign-up and accurate conversion math.' }
  'best-free-online-video-compressors-2026.html' = @{ Title = 'Best Free Online Video Compressors Compared | Toolzspan Blog'; Meta = 'Discover the best free online video compressors. Reduce video file size without quality loss using browser-based tools that need no sign-up or installation.' }
  'how-to-compress-gif-file-online.html' = @{ Title = 'How to Compress a GIF File Online Free | Toolzspan Blog'; Meta = 'Compress a GIF file online for free without losing animation quality. Reduce GIF size for web pages, email, social media, and faster website loading times.' }
  'how-to-compress-video-without-losing-quality.html' = @{ Title = 'Compress a Video Without Losing Quality | Toolzspan Blog'; Meta = 'Compress a video file without losing quality. Free methods, codec comparisons, expert tips, and step-by-step instructions for smaller MP4, MOV, and AVI files.' }
  'how-to-convert-avi-to-mp4-online-free.html' = @{ Title = 'How to Convert AVI to MP4 Online Free | Toolzspan Blog'; Meta = 'Convert AVI to MP4 online for free. Open older AVI videos on iPhone, Android, and modern devices using a fast browser tool with no software download required.' }
  'how-to-convert-heic-to-jpg-online-free.html' = @{ Title = 'How to Convert HEIC to JPG Online Free | Toolzspan Blog'; Meta = 'Convert HEIC to JPG online for free. Open iPhone photos on Windows, Android, Linux, and any device instantly with a browser tool that needs no install or app.' }
  'how-to-convert-jpg-to-png-online-free.html' = @{ Title = 'How to Convert JPG to PNG Online Free | Toolzspan Blog'; Meta = 'Convert JPG to PNG online for free with no quality loss. Preserve transparency, get crisp edges for screenshots, and convert images in your browser instantly.' }
  'how-to-convert-jpg-to-webp-online-free.html' = @{ Title = 'How to Convert JPG to WEBP Online Free | Toolzspan Blog'; Meta = 'Convert JPG to WEBP online for free to get smaller image files for faster website loading. Step-by-step guide to modern web image compression in any browser.' }
  'how-to-convert-mov-to-mp4-online-free.html' = @{ Title = 'How to Convert MOV to MP4 Online Free | Toolzspan Blog'; Meta = 'Convert MOV to MP4 online for free. Open iPhone videos on Windows, Android, and any platform with a browser tool that needs no software install or sign-up.' }
  'how-to-convert-mp4-to-mp3-online-free.html' = @{ Title = 'How to Convert MP4 to MP3 Online for Free | Toolzspan Blog'; Meta = 'Convert MP4 to MP3 online for free. Extract audio from any video file in seconds using a browser tool - no sign-up, no install, no upload to a remote server.' }
  'how-to-convert-png-to-jpg-online-free.html' = @{ Title = 'How to Convert PNG to JPG Online Free | Toolzspan Blog'; Meta = 'Convert PNG to JPG online for free to reduce image file size instantly while keeping great visual quality. Browser tool, no upload, no install, no account.' }
  'how-to-convert-png-to-webp-online-free.html' = @{ Title = 'How to Convert PNG to WEBP Online Free | Toolzspan Blog'; Meta = 'Convert PNG to WEBP online for free to reduce image file size dramatically for web optimization, faster page loads, and lower bandwidth on every visitor.' }
  'how-to-convert-time-zones-online-free.html' = @{ Title = 'How to Convert Time Zones Online Free | Toolzspan Blog'; Meta = 'Convert time zones online for free. Find the current time in any city, schedule meetings across countries, and avoid time-zone math errors with a fast tool.' }
  'how-to-make-gif-from-video-online-free.html' = @{ Title = 'How to Make a GIF from a Video Online Free | Toolzspan Blog'; Meta = 'Make a GIF from a video online for free. Convert short clips into looping animated GIFs for chat, social posts, and reactions with a browser tool, no install.' }
  'how-to-trim-audio-online-free.html' = @{ Title = 'How to Trim Audio Online for Free Easily | Toolzspan Blog'; Meta = 'Trim and cut audio files online for free using a visual waveform editor. Step-by-step guide for MP3, WAV, OGG, M4A trimming with no software install needed.' }
  'mp3-vs-mp4-difference-and-how-to-convert.html' = @{ Title = 'MP3 vs MP4: Difference and How to Convert | Toolzspan Blog'; Meta = 'MP3 vs MP4: learn the difference between the audio and video formats, when to use each, and how to convert between them for free in your browser, step by step.' }
  'webp-to-jpg-convert-webp-images-online-free.html' = @{ Title = 'How to Convert WEBP to JPG Online Free | Toolzspan Blog'; Meta = 'Convert WEBP to JPG online for free. Open WEBP images on devices that do not support the format, share them anywhere, and convert in seconds with a browser tool.' }
  'webp-to-png-convert-webp-to-png-online-free.html' = @{ Title = 'How to Convert WEBP to PNG Online Free | Toolzspan Blog'; Meta = 'Convert WEBP to PNG online for free. Preserve full image quality with lossless PNG output, support transparency, and convert images directly in your browser.' }
}

function Edit-BlogFile {
  param(
    [string]$Path,
    [string]$NewTitle,
    [string]$NewMeta
  )

  $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  $original = $content

  # 1. <title>...</title>
  $content = [regex]::Replace($content, '<title>[^<]*</title>', "<title>$NewTitle</title>", 'Singleline')

  # 2. <meta name="description" content="...">
  $content = [regex]::Replace($content, '<meta\s+name="description"\s+content="[^"]*"\s*/?>', "<meta name=`"description`" content=`"$NewMeta`">", 'Singleline')

  # 3. <meta property="og:title" content="...">
  $content = [regex]::Replace($content, '<meta\s+property="og:title"\s+content="[^"]*"\s*/?>', "<meta property=`"og:title`" content=`"$NewTitle`">", 'Singleline')

  # 4. <meta property="og:description" content="...">
  $content = [regex]::Replace($content, '<meta\s+property="og:description"\s+content="[^"]*"\s*/?>', "<meta property=`"og:description`" content=`"$NewMeta`">", 'Singleline')

  # 5. twitter:title - replace if exists, else insert after twitter:card
  if ($content -match '<meta\s+name="twitter:title"\s+content="[^"]*"\s*/?>') {
    $content = [regex]::Replace($content, '<meta\s+name="twitter:title"\s+content="[^"]*"\s*/?>', "<meta name=`"twitter:title`" content=`"$NewTitle`">", 'Singleline')
  } else {
    # Insert after twitter:card
    $content = [regex]::Replace($content, '(<meta\s+name="twitter:card"\s+content="[^"]*"\s*/?>)', "`$1`r`n  <meta name=`"twitter:title`" content=`"$NewTitle`">", 'Singleline')
  }

  # 6. twitter:description - replace if exists, else insert after twitter:title
  if ($content -match '<meta\s+name="twitter:description"\s+content="[^"]*"\s*/?>') {
    $content = [regex]::Replace($content, '<meta\s+name="twitter:description"\s+content="[^"]*"\s*/?>', "<meta name=`"twitter:description`" content=`"$NewMeta`">", 'Singleline')
  } else {
    $content = [regex]::Replace($content, '(<meta\s+name="twitter:title"\s+content="[^"]*"\s*/?>)', "`$1`r`n  <meta name=`"twitter:description`" content=`"$NewMeta`">", 'Singleline')
  }

  # 7. JSON-LD Article schema headline + description
  # The Article schema is in a single-line JSON inside <script type="application/ld+json">
  # Strip the title's " | Toolzspan Blog" suffix for the headline (cleaner schema)
  $headlineForSchema = $NewTitle -replace ' \| Toolzspan Blog$', ''
  # Escape special chars for JSON
  $jsonHeadline = $headlineForSchema -replace '\\', '\\' -replace '"', '\"'
  $jsonDescription = $NewMeta -replace '\\', '\\' -replace '"', '\"'

  $content = [regex]::Replace($content, '("@type"\s*:\s*"Article"[^}]*?"headline"\s*:\s*")[^"]*(")', "`${1}$jsonHeadline`${2}", 'Singleline')
  $content = [regex]::Replace($content, '("@type"\s*:\s*"Article"[^}]*?"description"\s*:\s*")[^"]*(")', "`${1}$jsonDescription`${2}", 'Singleline')

  if ($content -ne $original) {
    Set-Content -LiteralPath $Path -Value $content -Encoding UTF8 -NoNewline
    return $true
  }
  return $false
}

$updated = 0; $skipped = 0; $errors = @()
foreach ($file in ($map.Keys | Sort-Object)) {
  $path = Join-Path $blogDir $file
  if (-not (Test-Path $path)) {
    $errors += "MISSING: $file"
    continue
  }
  try {
    $changed = Edit-BlogFile -Path $path -NewTitle $map[$file].Title -NewMeta $map[$file].Meta
    if ($changed) { $updated++ } else { $skipped++ }
  } catch {
    $errors += "ERROR on $($file): $($_.Exception.Message)"
  }
}

Write-Host ""
Write-Host "Updated: $updated"
Write-Host "Skipped (no change): $skipped"
if ($errors.Count -gt 0) {
  Write-Host ""
  Write-Host "Issues:"
  $errors | ForEach-Object { Write-Host "  - $_" }
}
