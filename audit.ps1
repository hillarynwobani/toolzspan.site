$root = "c:\GravityProject\toolzspan.site"

Write-Output "============================================"
Write-Output "TOOLZSPAN COMPREHENSIVE BUG AUDIT"
Write-Output "============================================"

# 1. CONTACT FORM
Write-Output ""
Write-Output "=== 1. CONTACT FORM ==="
$contact = [System.IO.File]::ReadAllText("$root\contact.html")
if ($contact -notmatch 'action=') { Write-Output "  BUG: form tag has no action attribute - form cannot submit" }
if ($contact -notmatch 'method=') { Write-Output "  BUG: form tag has no method attribute" }
if ($contact -notmatch 'fetch\(|XMLHttpRequest') { Write-Output "  BUG: No JavaScript AJAX handler for form submission" }

# 2. MOBILE MENU CSS
Write-Output ""
Write-Output "=== 2. MOBILE MENU CSS ==="
$css = [System.IO.File]::ReadAllText("$root\css\style.css")
if ($css -notmatch 'accordion-open.*arrow|\.nav-tab\.accordion-open') { Write-Output "  BUG: No arrow rotation for accordion-open state on mobile" }
if ($css -notmatch 'mega-col\s*\{[^}]*display') { Write-Output "  INFO: mega-col has no explicit display rule in mobile query" }

# 3. MAIN.JS
Write-Output ""
Write-Output "=== 3. MAIN.JS ==="
$mainjs = [System.IO.File]::ReadAllText("$root\js\main.js")
if ($mainjs -notmatch 'resize') { Write-Output "  BUG: No window resize handler - mobile accordion breaks on orientation change" }
if ($mainjs -notmatch 'contactForm|contact-form') { Write-Output "  BUG: No contact form JavaScript handler in main.js" }
$lineCount = ($mainjs -split "`n").Count
Write-Output "  main.js is $lineCount lines (very minimal)"

# 4. TOOL PAGES AUDIT
Write-Output ""
Write-Output "=== 4. TOOL PAGES AUDIT ==="
Get-ChildItem "$root\tools\*.html" | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    $p = @()
    if ($c -notmatch 'class="dot"') { $p += "NO_DOTS" }
    if ($c -notmatch 'mega-view-all') { $p += "NO_VIEW_ALL" }
    if ($c -notmatch 'search-btn') { $p += "NO_SEARCH_BTN" }
    if ($c -notmatch 'logo-text') { $p += "NO_TEXT_LOGO_FOOTER" }
    if ($c -notmatch 'faq-item') { $p += "NO_FAQ" }
    if ($c -notmatch 'application/ld\+json') { $p += "NO_SCHEMA" }
    if ($c -notmatch 'og:title') { $p += "NO_OG_TAGS" }
    if ($c -notmatch 'canonical') { $p += "NO_CANONICAL" }
    if ($c -notmatch 'search\.js') { $p += "NO_SEARCH_JS" }
    if ($c -notmatch 'breadcrumb') { $p += "NO_BREADCRUMB" }
    if ($c -notmatch 'related-tool') { $p += "NO_RELATED_TOOLS" }
    if ($p.Count -gt 0) { Write-Output ("  " + $_.Name + ": " + ($p -join ", ")) }
}

# 5. BLOG PAGES AUDIT
Write-Output ""
Write-Output "=== 5. BLOG PAGES AUDIT ==="
Get-ChildItem "$root\blog\*.html" | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    $p = @()
    if ($c -notmatch 'class="dot"') { $p += "NO_DOTS" }
    if ($c -notmatch 'mega-view-all') { $p += "NO_VIEW_ALL" }
    if ($c -notmatch 'search-btn') { $p += "NO_SEARCH_BTN" }
    if ($c -notmatch 'logo-text') { $p += "NO_TEXT_LOGO_FOOTER" }
    if ($c -notmatch 'search\.js') { $p += "NO_SEARCH_JS" }
    if ($c -notmatch 'application/ld\+json') { $p += "NO_SCHEMA" }
    if ($_.Name -match 'post-' -and $c -notmatch 'faq-item') { $p += "NO_FAQ" }
    if ($_.Name -ne 'index.html' -and $c -notmatch 'related-posts') { $p += "NO_RELATED_POSTS" }
    if ($c -match 'mega-dropdown' -and $c -match 'href="mp4-converter\.html"') { $p += "RELATIVE_LINKS_IN_MENU" }
    if ($p.Count -gt 0) { Write-Output ("  " + $_.Name + ": " + ($p -join ", ")) }
}

# 6. CORE PAGES AUDIT
Write-Output ""
Write-Output "=== 6. CORE PAGES AUDIT ==="
$coreList = @("about.html","contact.html","privacy-policy.html","terms-of-service.html","404.html","index.html")
foreach ($pg in $coreList) {
    $fp = "$root\$pg"
    if (-not (Test-Path $fp)) { Write-Output ("  " + $pg + ": FILE_MISSING"); continue }
    $c = [System.IO.File]::ReadAllText($fp)
    $p = @()
    if ($c -notmatch 'class="dot"') { $p += "NO_DOTS" }
    if ($c -notmatch 'mega-view-all') { $p += "NO_VIEW_ALL" }
    if ($c -notmatch 'search-btn') { $p += "NO_SEARCH_BTN" }
    if ($c -notmatch 'logo-text') { $p += "NO_TEXT_LOGO_FOOTER" }
    if ($c -notmatch 'search\.js') { $p += "NO_SEARCH_JS" }
    if ($p.Count -gt 0) { Write-Output ("  " + $pg + ": " + ($p -join ", ")) }
}

# 7. SITEMAP COMPLETENESS
Write-Output ""
Write-Output "=== 7. SITEMAP AUDIT ==="
$sm = [System.IO.File]::ReadAllText("$root\sitemap.xml")
$toolFiles = Get-ChildItem "$root\tools\*.html" | Where-Object { $_.Name -ne "all-tools.html" }
foreach ($f in $toolFiles) {
    $url = "https://toolzspan.site/tools/" + $f.Name
    if ($sm -notmatch [regex]::Escape($url)) {
        Write-Output ("  MISSING from sitemap: " + $f.Name)
    }
}
# Check sitemap references files that dont exist
$sitemapToolUrls = [regex]::Matches($sm, 'toolzspan\.site/tools/([^<]+)')
foreach ($m in $sitemapToolUrls) {
    $filename = $m.Groups[1].Value
    if (-not (Test-Path "$root\tools\$filename")) {
        Write-Output ("  GHOST in sitemap (no file): tools/" + $filename)
    }
}
$sitemapBlogUrls = [regex]::Matches($sm, 'toolzspan\.site/blog/([^<]+)')
foreach ($m in $sitemapBlogUrls) {
    $filename = $m.Groups[1].Value
    if ($filename -ne "" -and -not (Test-Path "$root\blog\$filename")) {
        Write-Output ("  GHOST in sitemap (no file): blog/" + $filename)
    }
}
# Check blog files missing from sitemap
$blogFiles = Get-ChildItem "$root\blog\*.html" | Where-Object { $_.Name -ne "index.html" }
foreach ($f in $blogFiles) {
    $url = "https://toolzspan.site/blog/" + $f.Name
    if ($sm -notmatch [regex]::Escape($url)) {
        Write-Output ("  MISSING from sitemap: blog/" + $f.Name)
    }
}

# 8. ENCODING ISSUES (check for mojibake)
Write-Output ""
Write-Output "=== 8. ENCODING ISSUES ==="
$allHtml = Get-ChildItem "$root" -Recurse -Filter "*.html"
$encodingBugs = 0
foreach ($f in $allHtml) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    # Check for common UTF-8 mojibake patterns (raw bytes C3 A2 etc)
    if ($text -match '\xC3\xA2\xC2\x80\xC2\x94|\xC3\xA2\xC2\x80\xC2\x93') {
        $rel = $f.FullName.Replace($root, "")
        Write-Output ("  " + $rel + ": UTF-8 mojibake detected")
        $encodingBugs++
    }
}
# Also check for the visible garbled text
foreach ($f in $allHtml) {
    $c = [System.IO.File]::ReadAllText($f.FullName)
    if ($c.Contains([char]0xE2) -and $c.Contains([char]0x80)) {
        # This is normal for em-dashes etc, skip
    }
    # Check for the specific garbled alt text pattern
    if ($c -match 'alt="Toolzspan .{1,5} All-in-One' -and $c -notmatch 'alt="Toolzspan \x{2014} All') {
        $rel = $f.FullName.Replace($root, "")
        Write-Output ("  " + $rel + ": Logo alt text has garbled em-dash character")
        $encodingBugs++
    }
}
if ($encodingBugs -eq 0) { Write-Output "  Checking alt text for garbled characters..." }

# 9. FONT LOADING CONSISTENCY
Write-Output ""
Write-Output "=== 9. FONT LOADING ==="
$fontIssues = 0
foreach ($f in $allHtml) {
    $c = [System.IO.File]::ReadAllText($f.FullName)
    if ($c -match 'Playfair' -and $c -notmatch 'Space\+Grotesk') {
        Write-Output ("  " + $f.Name + ": Uses Playfair Display instead of Space Grotesk")
        $fontIssues++
    }
}
if ($fontIssues -eq 0) { Write-Output "  All pages use consistent fonts" } else { Write-Output "  $fontIssues pages have wrong font" }

# 10. BROKEN INTERNAL LINKS IN TOOL PAGES
Write-Output ""
Write-Output "=== 10. BROKEN LINK PATTERNS ==="
$brokenLinks = 0
foreach ($f in (Get-ChildItem "$root\tools\*.html")) {
    $c = [System.IO.File]::ReadAllText($f.FullName)
    $hrefs = [regex]::Matches($c, 'href="([a-z][a-z0-9-]+\.html[^"]*)"')
    foreach ($h in $hrefs) {
        $target = $h.Groups[1].Value -replace '#.*', ''
        if ($target -and -not (Test-Path "$root\tools\$target")) {
            Write-Output ("  " + $f.Name + " -> " + $target + " (FILE NOT FOUND)")
            $brokenLinks++
        }
    }
}
if ($brokenLinks -eq 0) { Write-Output "  No broken internal links in tool pages" }

# 11. ALL-TOOLS PAGE COMPLETENESS
Write-Output ""
Write-Output "=== 11. ALL-TOOLS PAGE COMPLETENESS ==="
$allToolsContent = [System.IO.File]::ReadAllText("$root\tools\all-tools.html")
$toolHtmlFiles = Get-ChildItem "$root\tools\*.html" | Where-Object { $_.Name -ne "all-tools.html" }
foreach ($f in $toolHtmlFiles) {
    if ($allToolsContent -notmatch [regex]::Escape($f.Name)) {
        Write-Output ("  MISSING from all-tools.html: " + $f.Name)
    }
}

# 12. HOMEPAGE TOOL COUNT
Write-Output ""
Write-Output "=== 12. HOMEPAGE TOOL COUNT ==="
$home = [System.IO.File]::ReadAllText("$root\index.html")
$actualToolCount = (Get-ChildItem "$root\tools\*.html" | Where-Object { $_.Name -ne "all-tools.html" }).Count
$taglineMatch = [regex]::Match($home, '(\d+)\s*Free Online Tools')
if ($taglineMatch.Success) {
    $claimed = [int]$taglineMatch.Groups[1].Value
    Write-Output ("  Homepage claims: " + $claimed + " tools")
    Write-Output ("  Actual tool files: " + $actualToolCount)
    if ($claimed -ne $actualToolCount) { Write-Output "  BUG: Mismatch!" }
}

# 13. SEARCH INDEX COMPLETENESS
Write-Output ""
Write-Output "=== 13. SEARCH INDEX ==="
$searchjs = [System.IO.File]::ReadAllText("$root\js\search.js")
foreach ($f in $toolHtmlFiles) {
    if ($searchjs -notmatch [regex]::Escape($f.Name)) {
        Write-Output ("  MISSING from search.js: " + $f.Name)
    }
}

# 14. CSS ISSUES
Write-Output ""
Write-Output "=== 14. CSS AUDIT ==="
if ($css -notmatch 'accordion-open.*\.arrow|\.nav-tab\.accordion-open\s') { Write-Output "  BUG: No arrow rotation styling for .accordion-open state" }
if ($css -notmatch '\.contact-form') { Write-Output "  INFO: No .contact-form CSS styles defined" }

# 15. CHECK LOGO ALT TEXT
Write-Output ""
Write-Output "=== 15. LOGO ALT TEXT CHECK ==="
$altBugs = 0
foreach ($f in $allHtml) {
    $c = [System.IO.File]::ReadAllText($f.FullName)
    $altMatches = [regex]::Matches($c, 'alt="([^"]*toolzspan[^"]*)"', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    foreach ($am in $altMatches) {
        $altVal = $am.Groups[1].Value
        if ($altVal -match '[^\x20-\x7E]' -and $altVal -notmatch '\x{2014}|\x{2013}') {
            $rel = $f.FullName.Replace($root, "")
            Write-Output ("  " + $rel + ": Garbled alt text: " + $altVal.Substring(0, [Math]::Min(60, $altVal.Length)))
            $altBugs++
        }
    }
}
if ($altBugs -eq 0) { Write-Output "  Checking..." }

Write-Output ""
Write-Output "============================================"
Write-Output "AUDIT COMPLETE"
Write-Output "============================================"
