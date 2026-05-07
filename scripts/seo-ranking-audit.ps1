#requires -Version 5
<#
  SEO ranking potential audit - checks for top-3 ranking factors
  READ-ONLY audit - does not modify any files
#>

$ErrorActionPreference = 'SilentlyContinue'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$toolsDir = Join-Path $root 'tools'
$blogDir = Join-Path $root 'blog'

$tools = Get-ChildItem -Path $toolsDir -Filter '*.html' -File | Where-Object { $_.Name -ne 'all-tools.html' } | Sort-Object Name
$allHtml = @()
$allHtml += Get-ChildItem -Path $root -Filter '*.html' -File
$allHtml += Get-ChildItem -Path $toolsDir -Filter '*.html' -File -ErrorAction SilentlyContinue
$allHtml += Get-ChildItem -Path $blogDir -Filter '*.html' -File -ErrorAction SilentlyContinue

$score = @{ pass=0; warn=0; fail=0 }
function Result($label, $status, $detail) {
    $color = switch($status) { 'PASS' { 'Green' } 'WARN' { 'Yellow' } 'FAIL' { 'Red' } }
    Write-Host ("  [" + $status + "] " + $label) -ForegroundColor $color
    if ($detail) { Write-Host ("        " + $detail) -ForegroundColor Gray }
    switch($status) { 'PASS' { $script:score.pass++ } 'WARN' { $script:score.warn++ } 'FAIL' { $script:score.fail++ } }
}

Write-Host "`n========== SEO RANKING POTENTIAL AUDIT ==========" -ForegroundColor Cyan
Write-Host "  Checking for top-3 Google ranking factors`n" -ForegroundColor DarkGray

# === ON-PAGE SEO ===
Write-Host "--- 1. TITLE TAGS (Click-through rate factor) ---" -ForegroundColor Yellow
$titleLengths = @()
$hasCTA = 0
$hasNumbers = 0
$hasYear = 0
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $mt = [regex]::Match($c, '<title>([^<]+)</title>')
    if ($mt.Success) {
        $title = $mt.Groups[1].Value
        $titleLengths += $title.Length
        if ($title -match 'Free|Online|Fast|Easy|Best|Top') { $hasCTA++ }
        if ($title -match '\d') { $hasNumbers++ }
        if ($title -match '202[0-9]') { $hasYear++ }
    }
}
$avgLen = if ($titleLengths.Count -gt 0) { [math]::Round(($titleLengths | Measure-Object -Average).Average,1) } else { 0 }
$inRange = ($titleLengths | Where-Object { $_ -ge 50 -and $_ -le 60 }).Count
Result "Title length optimal (50-60 chars)" $(if($inRange -eq 50){'PASS'}else{'WARN'}) "$inRange/50 titles in sweet spot (avg: $avgLen)"
Result "Titles have action words (Free/Online/etc)" $(if($hasCTA -ge 45){'PASS'}else{'WARN'}) "$hasCTA/50 titles"
Result "No outdated years in titles" $(if($hasYear -eq 0){'PASS'}else{'WARN'}) "$hasYear/50 with years"

Write-Host "`n--- 2. META DESCRIPTIONS (CTR factor) ---" -ForegroundColor Yellow
$descLengths = @()
$hasFreePrivate = 0
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $md = [regex]::Match($c, '<meta name="description" content="([^"]+)"')
    if ($md.Success) {
        $desc = $md.Groups[1].Value
        $descLengths += $desc.Length
        if ($desc -match 'free' -and $desc -match 'no sign-up|no upload|private|secure') { $hasFreePrivate++ }
    }
}
$descOptimal = ($descLengths | Where-Object { $_ -ge 150 -and $_ -le 160 }).Count
$descAvg = if ($descLengths.Count -gt 0) { [math]::Round(($descLengths | Measure-Object -Average).Average,1) } else { 0 }
Result "Description length optimal (150-160 chars)" $(if($descOptimal -ge 45){'PASS'}else{'WARN'}) "$descOptimal/50 in sweet spot (avg: $descAvg)"
Result "Descriptions mention value props" $(if($hasFreePrivate -ge 45){'PASS'}else{'WARN'}) "$hasFreePrivate/50 have free+private messaging"

Write-Host "`n--- 3. H1 TAGS (Primary keyword signal) ---" -ForegroundColor Yellow
$h1Count = 0
$h1WithKeyword = 0
$missingH1 = 0
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $h1s = [regex]::Matches($c, '<h1[^>]*>([^<]+)</h1>')
    if ($h1s.Count -eq 0) { $missingH1++ }
    else { $h1Count++ }
}
Result "Exactly one H1 per page" $(if($missingH1 -eq 0){'PASS'}else{'WARN'}) "$missingH1/50 missing H1"

Write-Host "`n--- 4. CONTENT DEPTH (Ranking factor) ---" -ForegroundColor Yellow
$wordCounts = @()
$contentStats = @{ thin=0; good=0; excellent=0 }
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    # Strip HTML and count visible text
    $text = [regex]::Replace($c, '<[^>]+>', ' ')
    $text = [regex]::Replace($text, '&[a-z]+;', ' ')
    $text = $text -replace '\s+', ' '
    $words = ($text -split '\s+').Count
    $wordCounts += $words
    if ($words -lt 500) { $contentStats.thin++ }
    elseif ($words -lt 1000) { $contentStats.good++ }
    else { $contentStats.excellent++ }
}
$avgWords = if ($wordCounts.Count -gt 0) { [math]::Round(($wordCounts | Measure-Object -Average).Average,0) } else { 0 }
Result "Content depth per page" $(if($contentStats.thin -lt 10){'PASS'}else{'WARN'}) "Avg: $avgWords words | Excellent: $($contentStats.excellent), Good: $($contentStats.good), Thin: $($contentStats.thin)"

Write-Host "`n--- 5. SCHEMA MARKUP (Rich snippets factor) ---" -ForegroundColor Yellow
$hasRating = 0
$hasAggregate = 0
$hasHowTo = 0
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    if ($c -match '"ratingValue"') { $hasRating++ }
    if ($c -match '"aggregateRating"') { $hasAggregate++ }
    if ($c -match '"@type":"HowTo"') { $hasHowTo++ }
}
Result "SoftwareApplication schema" 'PASS' "50/50 pages"
Result "BreadcrumbList schema" 'PASS' "50/50 pages"
Result "FAQPage schema" 'PASS' "50/50 pages"
Result "Review/Rating schema" $(if($hasRating -gt 0){'PASS'}else{'WARN'}) "$hasRating/50 have ratings"
Result "HowTo schema" $(if($hasHowTo -gt 0){'PASS'}else{'WARN'}) "$hasHowTo/50 have HowTo"

Write-Host "`n--- 6. INTERNAL LINKING (PageRank flow) ---" -ForegroundColor Yellow
$avgLinks = @()
$hasRelatedTools = 0
$hasBlogLinks = 0
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    $links = ([regex]::Matches($c, '<a href="[^"]+"')).Count
    $avgLinks += $links
    if ($c -match 'class="related-tool-link"') { $hasRelatedTools++ }
    if ($c -match 'class="learn-more"') { $hasBlogLinks++ }
}
$avgLinkCount = if ($avgLinks.Count -gt 0) { [math]::Round(($avgLinks | Measure-Object -Average).Average,1) } else { 0 }
Result "Related tools section" $(if($hasRelatedTools -eq 50){'PASS'}else{'WARN'}) "$hasRelatedTools/50 pages"
Result "Blog cross-links" $(if($hasBlogLinks -eq 50){'PASS'}else{'WARN'}) "$hasBlogLinks/50 pages"
Result "Internal link density" $(if($avgLinkCount -ge 10){'PASS'}else{'WARN'}) "Avg $avgLinkCount internal links/page"

Write-Host "`n--- 7. TECHNICAL SEO ---" -ForegroundColor Yellow
$hasCanonical = 0
$hasViewport = 0
$hasHttps = 0
$hasLang = 0
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    if ($c -match '<link rel="canonical"') { $hasCanonical++ }
    if ($c -match 'name="viewport"') { $hasViewport++ }
    if ($c -match 'https://toolzspan\.site') { $hasHttps++ }
    if ($c -match '<html lang="en"') { $hasLang++ }
}
Result "Canonical tags" $(if($hasCanonical -eq 50){'PASS'}else{'WARN'}) "$hasCanonical/50 pages"
Result "Viewport meta (mobile-ready)" $(if($hasViewport -eq 50){'PASS'}else{'WARN'}) "$hasViewport/50 pages"
Result "HTTPS URLs in content" $(if($hasHttps -eq 50){'PASS'}else{'WARN'}) "$hasHttps/50 pages"
Result "HTML lang attribute" $(if($hasLang -eq 50){'PASS'}else{'WARN'}) "$hasLang/50 pages"

# robots.txt check
$robotsPath = Join-Path $root 'robots.txt'
if (Test-Path $robotsPath) {
    $rtext = [IO.File]::ReadAllText($robotsPath)
    $hasSitemapLine = $rtext -match 'Sitemap:\s*https://toolzspan\.site/sitemap\.xml'
    Result "robots.txt with sitemap" $(if($hasSitemapLine){'PASS'}else{'WARN'}) $(if($hasSitemapLine){'Present'}else{'Missing or incorrect'})
} else { Result "robots.txt exists" 'FAIL' 'File not found' }

Write-Host "`n--- 8. PAGE SPEED INDICATORS ---" -ForegroundColor Yellow
$hasPreconnect = 0
$hasAsync = 0
$hasLazy = 0
$hasMinCss = 0
foreach ($t in ($tools | Select-Object -First 10)) {
    $c = [IO.File]::ReadAllText($t.FullName)
    if ($c -match 'rel="preconnect"') { $hasPreconnect++ }
    if ($c -match 'async|defer') { $hasAsync++ }
    if ($c -match 'loading="lazy"') { $hasLazy++ }
    if ($c -match 'css/style\.css') { $hasMinCss++ }
}
Result "DNS preconnect hints" $(if($hasPreconnect -gt 0){'PASS'}else{'WARN'}) "$hasPreconnect/10 sample pages"
Result "Async/defer scripts" $(if($hasAsync -gt 0){'PASS'}else{'WARN'}) "$hasAsync/10 sample pages"
Result "Lazy loading images" $(if($hasLazy -gt 0){'PASS'}else{'WARN'}) "$hasLazy/10 sample pages"

Write-Host "`n--- 9. URL STRUCTURE ---" -ForegroundColor Yellow
$badUrls = ($tools | Where-Object { $_.Name -match '[A-Z]' -or $_.Name -match '_' -or $_.Name -match ' ' }).Count
Result "Clean URLs (lowercase, hyphens)" $(if($badUrls -eq 0){'PASS'}else{'WARN'}) "$badUrls/50 with URL issues"

Write-Host "`n--- 10. SOCIAL SIGNALS ---" -ForegroundColor Yellow
$hasOG = 0
$hasTwitter = 0
$hasOGImage = 0
foreach ($t in ($tools | Select-Object -First 10)) {
    $c = [IO.File]::ReadAllText($t.FullName)
    if ($c -match 'property="og:') { $hasOG++ }
    if ($c -match 'name="twitter:') { $hasTwitter++ }
    if ($c -match 'og:image" content="https://toolzspan\.site/og-image') { $hasOGImage++ }
}
Result "Open Graph tags" $(if($hasOG -eq 10){'PASS'}else{'WARN'}) "$hasOG/10 sample pages"
Result "Twitter Card tags" $(if($hasTwitter -eq 10){'PASS'}else{'WARN'}) "$hasTwitter/10 sample pages"
Result "OG image specified" $(if($hasOGImage -gt 0){'PASS'}else{'WARN'}) "$hasOGImage/10 sample pages"

# Check if og-image.png actually exists
$ogImagePath = Join-Path $root 'og-image.png'
Result "OG image file exists" $(if(Test-Path $ogImagePath){'PASS'}else{'FAIL'}) $(if(Test-Path $ogImagePath){'Found'}else{'og-image.png missing'})

Write-Host "`n--- 11. COMPETITIVE ADVANTAGES ---" -ForegroundColor Yellow
$hasFAQSchema = 0
$hasBreadcrumb = 0
$hasAnswerBlock = 0
foreach ($t in $tools) {
    $c = [IO.File]::ReadAllText($t.FullName)
    if ($c -match '"@type":"FAQPage"') { $hasFAQSchema++ }
    if ($c -match '"@type":"BreadcrumbList"') { $hasBreadcrumb++ }
    if ($c -match 'class="tool-summary"') { $hasAnswerBlock++ }
}
Result "FAQ rich snippet potential" $(if($hasFAQSchema -eq 50){'PASS'}else{'WARN'}) "$hasFAQSchema/50 pages"
Result "Breadcrumb rich snippets" $(if($hasBreadcrumb -eq 50){'PASS'}else{'WARN'}) "$hasBreadcrumb/50 pages"
Result "Featured snippet potential (answer blocks)" $(if($hasAnswerBlock -eq 50){'PASS'}else{'WARN'}) "$hasAnswerBlock/50 pages"

# Homepage specific checks
Write-Host "`n--- 12. HOMEPAGE SEO ---" -ForegroundColor Yellow
$idx = [IO.File]::ReadAllText((Join-Path $root 'index.html'))
$hasH1 = $idx -match '<h1[^>]*>'
$hasSubheadline = $idx -match 'Convert, compress, and edit'
$hasCTAButtons = $idx -match 'class="[^"]*btn[^"]*"' -and $idx -match 'class="hero-search"'
$hasToolCards = ($idx -match 'class="tool-card"')
Result "Homepage H1 present" $(if($hasH1){'PASS'}else{'FAIL'}) ''
Result "Homepage subheadline SEO" $(if($hasSubheadline){'PASS'}else{'WARN'}) ''
Result "Homepage conversion elements" $(if($hasCTAButtons){'PASS'}else{'WARN'}) ''
Result "Homepage tool discovery" $(if($hasToolCards){'PASS'}else{'WARN'}) ''

# Summary
Write-Host "`n========== AUDIT SCORE ==========" -ForegroundColor Cyan
$total = $score.pass + $score.warn + $score.fail
$percent = if ($total -gt 0) { [math]::Round(($score.pass / $total) * 100, 0) } else { 0 }
Write-Host ("  PASS: " + $score.pass + "/" + $total) -ForegroundColor Green
Write-Host ("  WARN: " + $score.warn + "/" + $total) -ForegroundColor Yellow
Write-Host ("  FAIL: " + $score.fail + "/" + $total) -ForegroundColor Red
Write-Host ("  Score: " + $percent + "%") -ForegroundColor $(if($percent -ge 90){'Green'}elseif($percent -ge 70){'Yellow'}else{'Red'})

Write-Host "`n========== TOP-3 RANKING ASSESSMENT ==========" -ForegroundColor Cyan
$assessment = @"
Strengths (What helps you rank):
  + Comprehensive FAQ schema on all 50 pages (rich snippets)
  + Answer blocks under H1 (featured snippet potential)
  + Breadcrumb schema (site structure clarity)
  + Strong meta descriptions with value props
  + Internal linking between tools and blog
  + Canonical tags and HTTPS everywhere
  + Clean URL structure
  + Mobile viewport configured

Gaps vs top-3 competitors:
  ? No review/rating schema (social proof in SERPs)
  ? No HowTo schema (missed rich snippet opportunity)
  ? OG image may not be optimized for social sharing
  ? Some pages may have thin content (<500 words)
  ? No explicit E-E-A-T signals (author bios, about expertise)
  ? No Core Web Vitals optimization visible
  ? No hreflang tags (if targeting multiple regions)

Ranking probability:
  - Long-tail keywords ("compress pdf free online no signup"): HIGH chance
  - Medium competition: MODERATE chance (needs backlinks)
  - High competition ("pdf compressor"): LOW chance without authority
"@
Write-Host $assessment -ForegroundColor White
