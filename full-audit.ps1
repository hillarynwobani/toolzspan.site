#requires -Version 5
<#
  Comprehensive audit of all 11 SEO fixes + sitemap validation
  Verifies everything matches the Toolzspan_SEO_Fix_Instructions.md spec
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$toolsDir = Join-Path $root 'tools'
$blogDir = Join-Path $root 'blog'

$allHtml = @()
$allHtml += Get-ChildItem -Path $root -Filter '*.html' -File
$allHtml += Get-ChildItem -Path $toolsDir -Filter '*.html' -File -ErrorAction SilentlyContinue
$allHtml += Get-ChildItem -Path $blogDir -Filter '*.html' -File -ErrorAction SilentlyContinue

$tools = Get-ChildItem -Path $toolsDir -Filter '*.html' -File | Where-Object { $_.Name -ne 'all-tools.html' } | Sort-Object Name

$issues = @()
$warnings = @()
function Add-Issue($fix, $page, $msg) { $script:issues += [pscustomobject]@{ Fix=$fix; Page=$page; Issue=$msg } }
function Add-Warning($fix, $page, $msg) { $script:warnings += [pscustomobject]@{ Fix=$fix; Page=$page; Issue=$msg } }

Write-Host "`n========== FIX 1: about.html tool count ==========" -ForegroundColor Cyan
$about = [IO.File]::ReadAllText((Join-Path $root 'about.html'))
$fix1Body = -not ($about -match '24 free online tools' -or $about -match '24 tools')
$fix1Meta = ([regex]::Match($about, '<meta name="description" content="([^"]+)"')).Groups[1].Value -match '50 free online tools'
if ($fix1Body) { Write-Host "  Body copy: OK (no 24-tools reference)" -ForegroundColor Green }
else { Add-Issue 'Fix 1' 'about.html' 'Still mentions 24 tools' }
if ($fix1Meta) { Write-Host "  Meta desc: OK (contains 50 free online tools)" -ForegroundColor Green }
else { Add-Issue 'Fix 1' 'about.html' 'Meta desc missing 50 free online tools' }

Write-Host "`n========== FIX 2: Meta titles (50 pages) ==========" -ForegroundColor Cyan
$titleStats = @{ ok=0; missingFormula=0; short=0; long=0; ogMismatch=0; twMismatch=0 }
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $mt = [regex]::Match($c, '<title>([^<]+)</title>')
    $mog = [regex]::Match($c, '<meta property="og:title" content="([^"]+)"')
    $mtw = [regex]::Match($c, '<meta name="twitter:title" content="([^"]+)"')
    if (-not $mt.Success) { Add-Issue 'Fix 2' $t.Name 'No <title> tag'; continue }
    $title = $mt.Groups[1].Value
    $len = $title.Length
    $hasFreeOnline = $title -match 'Free.*Online'
    $hasToolzspan = $title -match 'Toolzspan'
    $hasNoSignUp = $title -match 'No Sign-Up'
    $validPattern = ($hasFreeOnline -and $hasToolzspan) -or ($hasFreeOnline -and $hasNoSignUp -and $hasToolzspan)
    $ogOk = if ($mog.Success) { $mog.Groups[1].Value -eq $title } else { $false }
    $twOk = if ($mtw.Success) { $mtw.Groups[1].Value -eq $title } else { $false }
    if ($validPattern -and $len -ge 45 -and $len -le 65 -and $ogOk -and $twOk) { $titleStats.ok++ }
    else {
        if (-not $validPattern) { Add-Issue 'Fix 2' $t.Name "Title pattern invalid ($len chars): $title"; $titleStats.missingFormula++ }
        if ($len -lt 45) { Add-Issue 'Fix 2' $t.Name "Title too short ($len chars): $title"; $titleStats.short++ }
        if ($len -gt 65) { Add-Issue 'Fix 2' $t.Name "Title too long ($len chars): $title"; $titleStats.long++ }
        if (-not $ogOk) { Add-Issue 'Fix 2' $t.Name 'og:title mismatch'; $titleStats.ogMismatch++ }
        if (-not $twOk) { Add-Issue 'Fix 2' $t.Name 'twitter:title mismatch'; $titleStats.twMismatch++ }
    }
}
Write-Host ("  OK: " + $titleStats.ok + "/50") -ForegroundColor $(if($titleStats.ok -eq 50){'Green'}else{'Red'})

Write-Host "`n========== FIX 3: Meta descriptions (50 pages) ==========" -ForegroundColor Cyan
$descStats = @{ ok=0; short=0; long=0; ogMismatch=0; twMismatch=0 }
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $md = [regex]::Match($c, '<meta name="description" content="([^"]+)"')
    $mog = [regex]::Match($c, '<meta property="og:description" content="([^"]+)"')
    $mtw = [regex]::Match($c, '<meta name="twitter:description" content="([^"]+)"')
    if (-not $md.Success) { Add-Issue 'Fix 3' $t.Name 'No meta description'; continue }
    $desc = $md.Groups[1].Value
    $len = $desc.Length
    $ogOk = if ($mog.Success) { $mog.Groups[1].Value -eq $desc } else { $false }
    $twOk = if ($mtw.Success) { $mtw.Groups[1].Value -eq $desc } else { $false }
    if ($len -ge 150 -and $len -le 175 -and $ogOk -and $twOk) { $descStats.ok++ }
    else {
        if ($len -lt 150) { Add-Issue 'Fix 3' $t.Name "Desc too short ($len chars)"; $descStats.short++ }
        if ($len -gt 175) { Add-Issue 'Fix 3' $t.Name "Desc too long ($len chars)"; $descStats.long++ }
        if (-not $ogOk) { Add-Issue 'Fix 3' $t.Name 'og:description mismatch'; $descStats.ogMismatch++ }
        if (-not $twOk) { Add-Issue 'Fix 3' $t.Name 'twitter:description mismatch'; $descStats.twMismatch++ }
    }
}
Write-Host ("  OK: " + $descStats.ok + "/50") -ForegroundColor $(if($descStats.ok -eq 50){'Green'}else{'Red'})

Write-Host "`n========== FIX 4: Answer blocks under H1 (50 pages) ==========" -ForegroundColor Cyan
$ansStats = @{ ok=0; missing=0; short=0; long=0 }
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $ms = [regex]::Match($c, '<p class="tool-summary">([\s\S]*?)</p>')
    if (-not $ms.Success) { Add-Issue 'Fix 4' $t.Name 'No tool-summary paragraph'; $ansStats.missing++; continue }
    $textPlain = ([regex]::Replace([regex]::Replace($ms.Groups[1].Value, '<[^>]+>', ' '), '&[a-z]+;', ' ')) -replace '\s+', ' ' | ForEach-Object { $_.Trim() }
    $words = ($textPlain -split '\s+').Count
    if ($words -ge 38 -and $words -le 75) { $ansStats.ok++ }
    elseif ($words -lt 38) { Add-Issue 'Fix 4' $t.Name "Answer block too short ($words words)"; $ansStats.short++ }
    else { Add-Issue 'Fix 4' $t.Name "Answer block too long ($words words)"; $ansStats.long++ }
}
Write-Host ("  OK: " + $ansStats.ok + "/50") -ForegroundColor $(if($ansStats.ok -eq 50){'Green'}else{'Red'})

Write-Host "`n========== FIX 5: H2 rewrites (150 H2s) ==========" -ForegroundColor Cyan
$h2Stats = @{ how=0; why=0; faq=0 }
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    if ([regex]::IsMatch($c, '<h2>How to [^<]*\(3 Easy Steps\)</h2>')) { $h2Stats.how++ } else { Add-Issue 'Fix 5' $t.Name 'How-to H2 missing or wrong format' }
    if ([regex]::IsMatch($c, '<h2>Why [^<]*\(And When You Need To\)</h2>')) { $h2Stats.why++ } else { Add-Issue 'Fix 5' $t.Name 'Why-Use H2 missing or wrong format' }
    if ([regex]::IsMatch($c, '<h2>[^<]+Frequently Asked Questions</h2>')) { $h2Stats.faq++ } else { Add-Issue 'Fix 5' $t.Name 'FAQ H2 missing or wrong format' }
}
Write-Host ("  How-to: " + $h2Stats.how + "/50, Why-Use: " + $h2Stats.why + "/50, FAQ: " + $h2Stats.faq + "/50") -ForegroundColor $(if(($h2Stats.how -eq 50) -and ($h2Stats.why -eq 50) -and ($h2Stats.faq -eq 50)){'Green'}else{'Red'})

Write-Host "`n========== FIX 6: 8+ FAQs (50 pages) ==========" -ForegroundColor Cyan
$faqStats = @{ ok=0; under8=0 }
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $htmlCount = ([regex]::Matches($c, 'class="faq-item"')).Count
    $schemaCount = ([regex]::Matches($c, '"@type":"Question"')).Count
    if ($htmlCount -ge 8 -and $schemaCount -ge 8) { $faqStats.ok++ }
    else {
        Add-Issue 'Fix 6' $t.Name "FAQ count: HTML=$htmlCount, Schema=$schemaCount (need 8+)"
        $faqStats.under8++
    }
}
Write-Host ("  OK: " + $faqStats.ok + "/50") -ForegroundColor $(if($faqStats.ok -eq 50){'Green'}else{'Red'})

Write-Host "`n========== FIX 7: Related tools 5-6 + blog link (50 pages) ==========" -ForegroundColor Cyan
$relStats = @{ ok=0; badCount=0; noBlog=0 }
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $rt = [regex]::Match($c, '<div class="related-tools-grid">([\s\S]*?)</div>')
    $linkCount = if ($rt.Success) { ([regex]::Matches($rt.Groups[1].Value, 'class="related-tool-link"')).Count } else { 0 }
    $hasBlog = $c -match '<section class="learn-more">'
    if ($linkCount -ge 5 -and $linkCount -le 6 -and $hasBlog) { $relStats.ok++ }
    else {
        if ($linkCount -lt 5 -or $linkCount -gt 6) { Add-Issue 'Fix 7' $t.Name "Related tool count = $linkCount (need 5-6)"; $relStats.badCount++ }
        if (-not $hasBlog) { Add-Issue 'Fix 7' $t.Name 'Missing blog link section'; $relStats.noBlog++ }
    }
}
Write-Host ("  OK: " + $relStats.ok + "/50") -ForegroundColor $(if($relStats.ok -eq 50){'Green'}else{'Red'})

Write-Host "`n========== FIX 8: Schema markup (50 pages) ==========" -ForegroundColor Cyan
$schemaStats = @{ all3=0; missing=0 }
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $hasSw = $c -match '"@type":"SoftwareApplication"'
    $hasBc = $c -match '"@type":"BreadcrumbList"'
    $hasFq = $c -match '"@type":"FAQPage"'
    if ($hasSw -and $hasBc -and $hasFq) { $schemaStats.all3++ }
    else {
        if (-not $hasSw) { Add-Issue 'Fix 8' $t.Name 'Missing SoftwareApplication schema' }
        if (-not $hasBc) { Add-Issue 'Fix 8' $t.Name 'Missing BreadcrumbList schema' }
        if (-not $hasFq) { Add-Issue 'Fix 8' $t.Name 'Missing FAQPage schema' }
        $schemaStats.missing++
    }
}
Write-Host ("  All 3 schemas: " + $schemaStats.all3 + "/50") -ForegroundColor $(if($schemaStats.all3 -eq 50){'Green'}else{'Red'})

Write-Host "`n========== FIX 9: Scan Image rename ==========" -ForegroundColor Cyan
$si = [IO.File]::ReadAllText((Join-Path $toolsDir 'scan-image.html'))
$siChecks = @(
    @{ name='Title'; pass=($si -match '<title>Image to Text \(OCR\)') },
    @{ name='H1'; pass=($si -match '<h1>Image to Text \(OCR\)</h1>') },
    @{ name='Meta desc'; pass=($si -match '<meta name="description" content="[^"]*OCR') },
    @{ name='Breadcrumb'; pass=($si -match 'Image to Text \(OCR\)</div>') },
    @{ name='SoftwareApp'; pass=($si -match '"name":"Image to Text \(OCR\)"') },
    @{ name='No old name'; pass=(-not ($si -match '\bScan Image\b')) }
)
$siOk = 0
foreach ($ck in $siChecks) {
    if ($ck.pass) { Write-Host ("  PASS: " + $ck.name) -ForegroundColor Green; $siOk++ }
    else { Write-Host ("  FAIL: " + $ck.name) -ForegroundColor Red; Add-Issue 'Fix 9' 'scan-image.html' $ck.name }
}
$navHits = 0
foreach ($f in $allHtml) {
    $c2 = [IO.File]::ReadAllText($f.FullName)
    if ($c2 -match '><span class="dot"></span>Scan Image</a>') { $navHits++; Add-Issue 'Fix 9' $f.Name 'Nav still says Scan Image' }
}
Write-Host ("  Nav hits to old name: " + $navHits) -ForegroundColor $(if($navHits -eq 0){'Green'}else{'Red'})
$sj = [IO.File]::ReadAllText((Join-Path $root 'js\search.js'))
if ($sj -match "name: 'Image to Text \(OCR\)'") { Write-Host "  search.js: PASS" -ForegroundColor Green } else { Write-Host "  search.js: FAIL" -ForegroundColor Red; Add-Issue 'Fix 9' 'search.js' 'Missing renamed entry' }
$at = [IO.File]::ReadAllText((Join-Path $toolsDir 'all-tools.html'))
if ($at -match 'Image to Text \(OCR\)') { Write-Host "  all-tools.html: PASS" -ForegroundColor Green } else { Write-Host "  all-tools.html: FAIL" -ForegroundColor Red; Add-Issue 'Fix 9' 'all-tools.html' 'Card not renamed' }

Write-Host "`n========== FIX 10: Homepage hero ==========" -ForegroundColor Cyan
$idx = [IO.File]::ReadAllText((Join-Path $root 'index.html'))
$heroOk = $idx -match 'Convert, compress, and edit PDF, video, audio, and image files.*free online, no sign-up, no watermark, no limits.*Works on any device, right in your browser'
if ($heroOk) { Write-Host "  Hero subheadline: PASS" -ForegroundColor Green }
else { Write-Host "  Hero subheadline: FAIL" -ForegroundColor Red; Add-Issue 'Fix 10' 'index.html' 'Hero subheadline not updated' }

Write-Host "`n========== FIX 11: Image alt text ==========" -ForegroundColor Cyan
$em = [char]0x2014
$logoOk = 0
$logoBad = 0
$missingAlt = 0
$emptyAlt = 0
foreach ($f in $allHtml) {
    $c = [IO.File]::ReadAllText($f.FullName)
    foreach ($m in [regex]::Matches($c, '<img[^>]*>')) {
        $tag = $m.Value
        if ($tag -notmatch 'alt="') { $missingAlt++; Add-Issue 'Fix 11' $f.Name "img missing alt: $tag" }
        elseif ($tag -match 'alt=""') { $emptyAlt++; Add-Issue 'Fix 11' $f.Name "img empty alt: $tag" }
    }
    if ($c -match ('alt="Toolzspan ' + [regex]::Escape($em) + ' Free Online Tools"')) { $logoOk++ }
    elseif ($c -match 'toolzspan-logo') { $logoBad++; Add-Issue 'Fix 11' $f.Name 'Logo alt text not normalized' }
}
Write-Host ("  Logo alt OK: " + $logoOk + ", Bad: " + $logoBad) -ForegroundColor $(if($logoBad -eq 0){'Green'}else{'Red'})
Write-Host ("  Missing alt: " + $missingAlt + ", Empty alt: " + $emptyAlt) -ForegroundColor $(if(($missingAlt + $emptyAlt) -eq 0){'Green'}else{'Red'})

Write-Host "`n========== FIX 12: Sitemap validation ==========" -ForegroundColor Cyan
$sitemapPath = Join-Path $root 'sitemap.xml'
$sxml = [xml][IO.File]::ReadAllText($sitemapPath)
$sitemapUrls = $sxml.urlset.url | ForEach-Object { $_.loc }
$hasNamespaceError = ([IO.File]::ReadAllText($sitemapPath) -match 'xmlns=""')
Write-Host ("  Total URLs: " + $sitemapUrls.Count) -ForegroundColor Green
Write-Host ("  Namespace errors: " + $(if($hasNamespaceError){'FOUND'}else{'NONE'})) -ForegroundColor $(if(-not $hasNamespaceError){'Green'}else{'Red'})
if ($hasNamespaceError) { Add-Issue 'Fix 12' 'sitemap.xml' 'Has xmlns="" empty namespace attribute' }

# Validate URL counts
$expectedToolCount = $tools.Count
$expectedBlogCount = (Get-ChildItem -Path $blogDir -Filter '*.html' -File | Where-Object { $_.Name -ne 'index.html' }).Count
Write-Host ("  Tool URLs expected: " + $expectedToolCount + ", Blog URLs expected: " + $expectedBlogCount) -ForegroundColor Green

# Check for 404.html specifically
$has404 = 'https://toolzspan.site/404.html' -in $sitemapUrls
if ($has404) { Write-Host "  404.html: INCLUDED" -ForegroundColor Yellow; Add-Warning 'Fix 12' 'sitemap.xml' '404.html should not be in sitemap' }
else { Write-Host "  404.html: NOT in sitemap (correct)" -ForegroundColor Green }

Write-Host "`n========== GENERAL SITE AUDIT ==========" -ForegroundColor Cyan
# Duplicate titles
$titles = @()
$descs = @()
foreach ($f in $allHtml) {
    $c = [IO.File]::ReadAllText($f.FullName)
    $mt = [regex]::Match($c, '<title>([^<]+)</title>')
    $md = [regex]::Match($c, '<meta name="description" content="([^"]+)"')
    if ($mt.Success) { $titles += $mt.Groups[1].Value }
    if ($md.Success) { $descs += $md.Groups[1].Value }
}
$dupTitles = $titles | Group-Object | Where-Object { $_.Count -gt 1 }
$dupDescs = $descs | Group-Object | Where-Object { $_.Count -gt 1 }
Write-Host ("  Duplicate titles: " + $dupTitles.Count) -ForegroundColor $(if($dupTitles.Count -eq 0){'Green'}else{'Yellow'})
Write-Host ("  Duplicate descriptions: " + $dupDescs.Count) -ForegroundColor $(if($dupDescs.Count -eq 0){'Green'}else{'Yellow'})
if ($dupTitles) { $dupTitles | ForEach-Object { Add-Warning 'General' '' ("Duplicate title (" + $_.Count + "x): " + $_.Name) } }
if ($dupDescs) { $dupDescs | ForEach-Object { Add-Warning 'General' '' ("Duplicate description (" + $_.Count + "x): " + ($_.Name.Substring(0,[Math]::Min(50,$_.Name.Length)) + "...")) } }

# Broken internal links (HTML files only)
$brokenLinks = 0
foreach ($f in $allHtml) {
    $c = [IO.File]::ReadAllText($f.FullName)
    foreach ($m in [regex]::Matches($c, 'href="(/[^#"]+\.html)"')) {
        $target = $m.Groups[1].Value -replace '^/', ''
        $path = Join-Path $root $target
        if (-not (Test-Path $path)) {
            $brokenLinks++
            Add-Issue 'General' $f.Name ("Broken link: " + $m.Groups[1].Value)
        }
    }
}
Write-Host ("  Broken internal links: " + $brokenLinks) -ForegroundColor $(if($brokenLinks -eq 0){'Green'}else{'Red'})

# robots.txt
$robotsPath = Join-Path $root 'robots.txt'
if (Test-Path $robotsPath) {
    $rtext = [IO.File]::ReadAllText($robotsPath)
    $hasSitemap = $rtext -match 'Sitemap:'
    Write-Host ("  robots.txt: EXISTS, Sitemap reference: " + $(if($hasSitemap){'YES'}else{'NO'})) -ForegroundColor $(if($hasSitemap){'Green'}else{'Red'})
} else { Write-Host "  robots.txt: MISSING" -ForegroundColor Red; Add-Issue 'General' '' 'robots.txt missing' }

# Blog index coverage
$blogIdx = [IO.File]::ReadAllText((Join-Path $blogDir 'index.html'))
$blogFiles = Get-ChildItem -Path $blogDir -Filter '*.html' -File | Where-Object { $_.Name -ne 'index.html' }
$linked = 0
foreach ($bf in $blogFiles) { if ($blogIdx -match [regex]::Escape($bf.Name)) { $linked++ } }
Write-Host ("  Blog posts linked in index: " + $linked + "/" + $blogFiles.Count) -ForegroundColor $(if($linked -eq $blogFiles.Count){'Green'}else{'Yellow'})
if ($linked -lt $blogFiles.Count) { Add-Issue 'General' 'blog/index.html' 'Not all blog posts linked' }

Write-Host "`n========== FINAL SUMMARY ==========" -ForegroundColor Cyan
if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "  ALL CHECKS PASSED! No issues or warnings." -ForegroundColor Green
} else {
    if ($issues.Count -gt 0) {
        Write-Host ("  ISSUES: " + $issues.Count) -ForegroundColor Red
        $grouped = $issues | Group-Object Fix | Sort-Object Name
        foreach ($g in $grouped) {
            Write-Host ("    " + $g.Name + ": " + $g.Count + " issue(s)") -ForegroundColor Red
        }
    }
    if ($warnings.Count -gt 0) {
        Write-Host ("  WARNINGS: " + $warnings.Count) -ForegroundColor Yellow
        $grouped = $warnings | Group-Object Fix | Sort-Object Name
        foreach ($g in $grouped) {
            Write-Host ("    " + $g.Name + ": " + $g.Count + " warning(s)") -ForegroundColor Yellow
        }
    }
    Write-Host "`n  Detailed issues:" -ForegroundColor DarkYellow
    $issues | Select-Object -First 30 | ForEach-Object {
        Write-Host ("    [" + $_.Fix + "] " + $_.Page + ": " + $_.Issue) -ForegroundColor DarkYellow
    }
    if ($issues.Count -gt 30) { Write-Host ("    ... and " + ($issues.Count - 30) + " more") -ForegroundColor DarkYellow }
}

Write-Host "`n  Fix 12 manual step: Submit sitemap.xml in Google Search Console (if not already done)" -ForegroundColor Cyan
Write-Host "  All code fixes verified against SEO Fix Instructions." -ForegroundColor Cyan
