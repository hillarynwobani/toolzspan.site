# Toolzspan Fix Script v2 - Simple string replacement approach
$ErrorActionPreference = 'Stop'
$root = "c:\GravityProject\toolzspan.site"

# Build header HTML for tool pages (relative paths within /tools/)
$headerTools = @'
  <header class="site-header">
    <div class="header-inner">
      <a href="/" class="header-logo" aria-label="Toolzspan Home">
        <img src="../toolzspan-logo-v2.svg" alt="Toolzspan — All-in-One Free Online Tools" width="180" height="45" loading="eager">
        <span class="logo-tagline">49 Free Online Tools</span>
      </a>
      <button class="menu-toggle" aria-label="Toggle navigation" id="menuToggle">
        <span></span><span></span><span></span>
      </button>
      <nav class="nav-menu" id="navMenu">
        <div class="nav-tab" id="navConvert">Convert <span class="arrow">&#9660;</span>
          <div class="mega-dropdown">
            <div class="mega-col">
              <div class="mega-col-heading">Video &amp; Audio</div>
              <a href="mp4-converter.html"><span class="dot"></span>MP4 Converter</a>
              <a href="mp3-converter.html"><span class="dot"></span>MP3 Converter</a>
              <a href="mp4-to-mp3.html"><span class="dot"></span>MP4 to MP3</a>
              <a href="mp3-to-mp4.html"><span class="dot"></span>MP3 to MP4</a>
              <a href="avi-to-mp4.html"><span class="dot"></span>AVI to MP4</a>
              <a href="mov-to-mp4.html"><span class="dot"></span>MOV to MP4</a>
              <a href="webm-to-mp4.html"><span class="dot"></span>WebM to MP4</a>
              <a href="wav-to-mp3.html"><span class="dot"></span>WAV to MP3</a>
              <a href="ogg-to-mp3.html"><span class="dot"></span>OGG to MP3</a>
              <a href="all-tools.html#video-audio" class="mega-view-all">&rarr; View All Video &amp; Audio</a>
            </div>
            <div class="mega-col">
              <div class="mega-col-heading">Image</div>
              <a href="image-to-pdf.html"><span class="dot"></span>Image to PDF</a>
              <a href="pdf-to-image.html"><span class="dot"></span>PDF to Image</a>
              <a href="jpg-to-png.html"><span class="dot"></span>JPG to PNG</a>
              <a href="png-to-jpg.html"><span class="dot"></span>PNG to JPG</a>
              <a href="webp-to-jpg.html"><span class="dot"></span>WEBP to JPG</a>
              <a href="webp-to-png.html"><span class="dot"></span>WEBP to PNG</a>
              <a href="jpg-to-webp.html"><span class="dot"></span>JPG to WEBP</a>
              <a href="png-to-webp.html"><span class="dot"></span>PNG to WEBP</a>
              <a href="heic-to-jpg.html"><span class="dot"></span>HEIC to JPG</a>
              <a href="all-tools.html#image" class="mega-view-all">&rarr; View All Image Tools</a>
            </div>
            <div class="mega-col">
              <div class="mega-col-heading">PDF &amp; Documents</div>
              <a href="pdf-to-word.html"><span class="dot"></span>PDF to Word</a>
              <a href="word-to-pdf.html"><span class="dot"></span>Word to PDF</a>
              <a href="powerpoint-to-pdf.html"><span class="dot"></span>PowerPoint to PDF</a>
              <a href="excel-to-pdf.html"><span class="dot"></span>Excel to PDF</a>
              <a href="pdf-editor.html"><span class="dot"></span>PDF Editor</a>
              <a href="all-tools.html#pdf" class="mega-view-all">&rarr; View All PDF &amp; Docs</a>
            </div>
          </div>
        </div>
        <div class="nav-tab" id="navCompress">Compress <span class="arrow">&#9660;</span>
          <div class="mega-dropdown">
            <div class="mega-col">
              <div class="mega-col-heading">Video &amp; Audio</div>
              <a href="video-compressor.html"><span class="dot"></span>Video Compressor</a>
              <a href="compress-mp4.html"><span class="dot"></span>Compress MP4</a>
              <a href="audio-compressor.html"><span class="dot"></span>Audio Compressor</a>
              <a href="compress-mp3.html"><span class="dot"></span>Compress MP3</a>
              <a href="all-tools.html#compress" class="mega-view-all">&rarr; View All Compressors</a>
            </div>
            <div class="mega-col">
              <div class="mega-col-heading">Image</div>
              <a href="image-compressor.html"><span class="dot"></span>Image Compressor</a>
              <a href="gif-compressor.html"><span class="dot"></span>GIF Compressor</a>
            </div>
            <div class="mega-col">
              <div class="mega-col-heading">PDF</div>
              <a href="pdf-compressor.html"><span class="dot"></span>PDF Compressor</a>
            </div>
          </div>
        </div>
        <div class="nav-tab" id="navTools">Tools <span class="arrow">&#9660;</span>
          <div class="mega-dropdown">
            <div class="mega-col">
              <div class="mega-col-heading">PDF Tools</div>
              <a href="pdf-merger.html"><span class="dot"></span>PDF Merger</a>
              <a href="pdf-splitter.html"><span class="dot"></span>PDF Splitter</a>
              <a href="pdf-page-rotator.html"><span class="dot"></span>PDF Page Rotator</a>
              <a href="pdf-page-remover.html"><span class="dot"></span>PDF Page Remover</a>
              <a href="add-watermark-pdf.html"><span class="dot"></span>Add Watermark</a>
              <a href="add-password-pdf.html"><span class="dot"></span>Add Password</a>
              <a href="remove-password-pdf.html"><span class="dot"></span>Remove Password</a>
              <a href="sign-pdf.html"><span class="dot"></span>Sign PDF</a>
              <a href="ocr-pdf.html"><span class="dot"></span>OCR PDF</a>
              <a href="scan-image.html"><span class="dot"></span>Scan Image</a>
              <a href="all-tools.html#pdf-tools" class="mega-view-all">&rarr; View All PDF Tools</a>
            </div>
            <div class="mega-col">
              <div class="mega-col-heading">GIF Tools</div>
              <a href="gif-maker.html"><span class="dot"></span>GIF Maker</a>
              <a href="gif-converter.html"><span class="dot"></span>GIF Converter</a>
              <a href="all-tools.html#gif" class="mega-view-all">&rarr; View All GIF Tools</a>
            </div>
            <div class="mega-col">
              <div class="mega-col-heading">General</div>
              <a href="qr-code-generator.html"><span class="dot"></span>QR Code Generator</a>
              <a href="word-counter.html"><span class="dot"></span>Word Counter</a>
              <a href="color-picker.html"><span class="dot"></span>Color Picker</a>
              <a href="units-converter.html"><span class="dot"></span>Units Converter</a>
              <a href="time-converter.html"><span class="dot"></span>Time Converter</a>
              <a href="all-tools.html#general" class="mega-view-all">&rarr; View All General Tools</a>
            </div>
          </div>
        </div>
      </nav>
      <div class="nav-right">
        <div class="search-btn">&#128269;</div>
      </div>
    </div>
  </header>
'@

# Build header for blog/core pages (absolute /tools/ paths)
$headerAbsolute = $headerTools -replace 'href="([a-z])', 'href="/tools/$1'
$headerAbsolute = $headerAbsolute -replace 'href="all-tools', 'href="/tools/all-tools'

# For blog pages: logo path is ../
$headerBlog = $headerAbsolute
# For core pages: logo path is root-relative
$headerCore = $headerAbsolute -replace 'src="../toolzspan-logo-v2.svg"', 'src="toolzspan-logo-v2.svg"'

# Footer template
$footer = @'
  <footer class="site-footer">
    <div class="footer-inner">
      <div class="footer-grid">
        <div class="footer-brand">
          <span class="logo-text">
            <span class="toolz" style="color:#fff;">Toolz</span><span class="span">span</span>
          </span>
          <p>All-in-one free online tools for PDF, video, audio, and image processing. No sign-up. No limits.</p>
        </div>
        <div class="footer-col">
          <div class="footer-col-heading">Company</div>
          <a href="/about.html">About</a>
          <a href="/contact.html">Contact</a>
        </div>
        <div class="footer-col">
          <div class="footer-col-heading">Resources</div>
          <a href="/blog/">Blog</a>
          <a href="/tools/all-tools.html">All Tools</a>
          <a href="/sitemap.xml">Sitemap</a>
        </div>
        <div class="footer-col">
          <div class="footer-col-heading">Legal</div>
          <a href="/privacy-policy.html">Privacy Policy</a>
          <a href="/terms-of-service.html">Terms of Service</a>
        </div>
      </div>
      <div class="footer-bottom">
        <span class="copy">&copy; 2026 Toolzspan. All rights reserved.</span>
        <div class="footer-badges">
          <span class="badge">&#128274; Secure</span>
          <span class="badge">&#9889; Fast</span>
          <span class="badge">&#9989; Free</span>
        </div>
      </div>
    </div>
  </footer>
'@

# FAQ HTML block
$faqHtml = @'

<h2 id="faq">Frequently Asked Questions</h2>
<div class="faq-item"><button class="faq-question">Do I have to pay to use this tool?</button><div class="faq-answer"><p>No. All tools on Toolzspan are completely free to use. There are no hidden fees, subscriptions, or paywalls.</p></div></div>
<div class="faq-item"><button class="faq-question">Do I need to create an account or give my email?</button><div class="faq-answer"><p>No. We firmly believe that basic digital utilities should not require surrendering your personal data. You can use all tools anonymously.</p></div></div>
<div class="faq-item"><button class="faq-question">Is my file safe and private?</button><div class="faq-answer"><p>Privacy is a massive priority. Depending on the specific tool, your file is either processed entirely within your own local web browser (meaning it never touches the internet), or it is passed to a secure server, processed, and immediately purged. Data is never stored or viewed.</p></div></div>
<div class="faq-item"><button class="faq-question">Can I do this on my smartphone?</button><div class="faq-answer"><p>Yes. The interface is fully responsive. Whether you are on a desktop monitor, an iPad, or a smartphone, the tools will scale and function perfectly.</p></div></div>
'@

$faqSchema = '<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[{"@type":"Question","name":"Do I have to pay to use this tool?","acceptedAnswer":{"@type":"Answer","text":"No, all tools on Toolzspan are completely free to use."}},{"@type":"Question","name":"Do I need to create an account or give my email?","acceptedAnswer":{"@type":"Answer","text":"No. You can use the tools anonymously."}},{"@type":"Question","name":"Is my file safe and private?","acceptedAnswer":{"@type":"Answer","text":"Privacy is a priority. Files are processed locally or securely deleted after processing."}},{"@type":"Question","name":"Can I do this on my smartphone?","acceptedAnswer":{"@type":"Answer","text":"Yes. The interface is fully responsive and works on all mobile devices."}}]}</script>'

function Replace-HeaderFooter($filePath, $headerHtml, $footerHtml) {
    $content = [System.IO.File]::ReadAllText($filePath)
    
    # Replace header using regex
    $headerRegex = [regex]::new('<header class="site-header">.*?</header>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $content = $headerRegex.Replace($content, $headerHtml, 1)
    
    # Replace footer using regex
    $footerRegex = [regex]::new('<footer class="site-footer">.*?</footer>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $content = $footerRegex.Replace($content, $footerHtml, 1)
    
    [System.IO.File]::WriteAllText($filePath, $content)
}

# === TOOL PAGES ===
Write-Output "=== FIXING TOOL PAGES ==="
Get-ChildItem "$root\tools\*.html" | ForEach-Object {
    Replace-HeaderFooter $_.FullName $headerTools $footer
    Write-Output "  Fixed: $($_.Name)"
}

# === BLOG PAGES ===
Write-Output "`n=== FIXING BLOG PAGES ==="
Get-ChildItem "$root\blog\*.html" | ForEach-Object {
    Replace-HeaderFooter $_.FullName $headerBlog $footer
    Write-Output "  Fixed: $($_.Name)"
}

# === CORE PAGES ===
Write-Output "`n=== FIXING CORE PAGES ==="
@("about.html","contact.html","privacy-policy.html","terms-of-service.html","404.html") | ForEach-Object {
    $fp = "$root\$_"
    if (Test-Path $fp) {
        Replace-HeaderFooter $fp $headerCore $footer
        Write-Output "  Fixed: $_"
    }
}

# === INJECT FAQ INTO OLD BLOG POSTS ===
Write-Output "`n=== INJECTING FAQ INTO OLD BLOG POSTS ==="
for ($i = 1; $i -le 22; $i++) {
    $num = $i.ToString("00")
    $fp = "$root\blog\post-$num.html"
    if (Test-Path $fp) {
        $content = [System.IO.File]::ReadAllText($fp)
        if ($content -match 'faq-item') {
            Write-Output "  Skipped (has FAQ): post-$num.html"
            continue
        }
        
        # Insert FAQ before related-posts or before </article>
        $relatedRegex = [regex]::new('<div class="related-posts">')
        if ($relatedRegex.IsMatch($content)) {
            $content = $relatedRegex.Replace($content, ($faqHtml + "`n" + '<div class="related-posts">'), 1)
        } elseif ($content.Contains('</article>')) {
            $content = $content.Replace('</article>', ($faqHtml + "`n</article>"))
        } else {
            $content = $content.Replace('</main>', ($faqHtml + "`n</main>"))
        }
        
        # Add FAQPage schema
        if (-not $content.Contains('FAQPage')) {
            $content = $content.Replace('</head>', ($faqSchema + "`n</head>"))
        }
        
        [System.IO.File]::WriteAllText($fp, $content)
        Write-Output "  Injected FAQ: post-$num.html"
    }
}

# === FINAL AUDIT ===
Write-Output "`n=== FINAL AUDIT ==="
$issues = 0

$allFiles = @()
$allFiles += Get-ChildItem "$root\tools\*.html"
$allFiles += Get-ChildItem "$root\blog\*.html"
@("about.html","contact.html","privacy-policy.html","terms-of-service.html","404.html") | ForEach-Object {
    $fp = "$root\$_"
    if (Test-Path $fp) { $allFiles += Get-Item $fp }
}

foreach ($f in $allFiles) {
    $c = [System.IO.File]::ReadAllText($f.FullName)
    $problems = @()
    if ($c -notmatch 'class="dot"') { $problems += "NO_DOTS" }
    if ($c -notmatch 'mega-view-all') { $problems += "NO_VIEW_ALL" }
    if ($c -notmatch 'search-btn') { $problems += "NO_SEARCH_BTN" }
    if ($c -notmatch 'logo-text') { $problems += "NO_TEXT_LOGO" }
    if ($problems.Count -gt 0) {
        Write-Output "  FAIL: $($f.Name) - $($problems -join ', ')"
        $issues++
    }
}

# Blog link check
$blogBroken = 0
Get-ChildItem "$root\blog\*.html" | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    if ($c -match 'mega-dropdown' -and $c -match 'href="mp4-converter\.html"') {
        Write-Output "  FAIL: $($_.Name) - RELATIVE_LINKS"
        $blogBroken++
    }
}

# Blog FAQ check
$blogNoFaq = 0
for ($i = 1; $i -le 22; $i++) {
    $num = $i.ToString("00")
    $fp = "$root\blog\post-$num.html"
    if (Test-Path $fp) {
        $c = [System.IO.File]::ReadAllText($fp)
        if ($c -notmatch 'faq-item') {
            Write-Output "  FAIL: post-$num.html - NO_FAQ"
            $blogNoFaq++
        }
    }
}

$total = $issues + $blogBroken + $blogNoFaq
if ($total -eq 0) {
    Write-Output "`n*** ALL PAGES PASS AUDIT ***"
} else {
    Write-Output "`nTotal issues: $total (header/footer: $issues, broken links: $blogBroken, missing FAQ: $blogNoFaq)"
}
Write-Output "Done!"
