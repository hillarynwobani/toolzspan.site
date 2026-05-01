# Fix-up pass for Phase B2/B3:
# 1. Insert missing twitter:card/title/description on posts 06-22
# 2. Update Article schema "description" field (regex was failing because nested {} in author/publisher)
# 3. Trim webp-to-jpg meta to <=160 chars

$ErrorActionPreference = 'Stop'
$blogDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'blog'

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
  'webp-to-jpg-convert-webp-images-online-free.html' = @{ Title = 'How to Convert WEBP to JPG Online Free | Toolzspan Blog'; Meta = 'Convert WEBP to JPG online for free. Open WEBP images on devices that lack native support, share them anywhere, and convert in seconds with a browser tool.' }
}

$updated = 0
foreach ($file in ($map.Keys | Sort-Object)) {
  $path = Join-Path $blogDir $file
  if (-not (Test-Path $path)) { continue }
  $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $original = $content
  $title = $map[$file].Title
  $meta = $map[$file].Meta

  # Fix 1: webp-to-jpg meta length
  if ($file -eq 'webp-to-jpg-convert-webp-images-online-free.html') {
    # Replace overly-long meta with shorter version everywhere
    $oldMeta = 'Convert WEBP to JPG online for free. Open WEBP images on devices that don''t support the format, share them anywhere, and convert in seconds with a browser tool.'
    $content = $content.Replace($oldMeta, $meta)
  }

  # Fix 2: Insert twitter tags if missing
  if ($content -notmatch '<meta name="twitter:card"') {
    # Insert after og:type
    $insertion = "`r`n  <meta name=`"twitter:card`" content=`"summary_large_image`">`r`n  <meta name=`"twitter:title`" content=`"$title`">`r`n  <meta name=`"twitter:description`" content=`"$meta`">"
    $content = [regex]::Replace($content, '(<meta\s+property="og:type"\s+content="[^"]*"\s*/?>)', "`$1$insertion", 'Singleline')
  }

  # Fix 3: Update Article JSON-LD description (use anchored regex within the Article script tag)
  # Match the entire Article JSON-LD block, then replace its "description" value
  $articlePattern = '(<script type="application/ld\+json">\s*\{[^<]*?"@type":"Article"[^<]*?\}\s*</script>)'
  $articleMatch = [regex]::Match($content, $articlePattern, 'Singleline')
  if ($articleMatch.Success) {
    $articleBlock = $articleMatch.Groups[1].Value
    $jsonDesc = $meta -replace '\\', '\\' -replace '"', '\"'
    if ($articleBlock -match '"description":"[^"]*"') {
      $newArticleBlock = [regex]::Replace($articleBlock, '"description":"[^"]*"', "`"description`":`"$jsonDesc`"")
    } else {
      # No description field - insert one before mainEntityOfPage
      $newArticleBlock = [regex]::Replace($articleBlock, '"mainEntityOfPage"', "`"description`":`"$jsonDesc`",`"mainEntityOfPage`"")
    }
    $content = $content.Replace($articleBlock, $newArticleBlock)
  }

  if ($content -ne $original) {
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
    $updated++
  }
}

Write-Host "Updated: $updated files"
