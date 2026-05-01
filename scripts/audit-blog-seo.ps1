# audit-blog-seo.ps1
# Read-only audit: validate every blog HTML file against the project's SEO guidelines.
#
# Guidelines (from apply-blog-seo.ps1 + strip-2026-year-tags.ps1):
#   1. <title> present, non-empty, ends with " | Toolzspan Blog", no "2026"
#   2. <meta name="description"> present, 120-170 chars, no "2026"
#   3. <link rel="canonical"> present, HTTPS, matches file name
#   4. og:title / og:description / og:url / og:type / og:site_name present
#   5. og:title and og:description MATCH <title>/meta description
#   6. twitter:card / twitter:title / twitter:description present and sync'd
#   7. JSON-LD @type=Article present with: headline, datePublished, author, publisher, mainEntityOfPage
#   8. JSON-LD headline has no " | Toolzspan Blog" suffix and no "2026"
#   9. Exactly one <h1> per page and it contains no "(2026)" / "in 2026" / "2026 Guide"
#   10. <html lang="en"> present

$ErrorActionPreference = 'Stop'

$blogDir = Join-Path $PSScriptRoot '..\blog'
$blogDir = (Resolve-Path $blogDir).Path

$files = Get-ChildItem -Path $blogDir -Filter '*.html' -File | Where-Object { $_.Name -ne 'index.html' }

$report = @()
$cleanFiles = 0
$filesWithIssues = 0

foreach ($f in $files) {
    $content = Get-Content -Raw -LiteralPath $f.FullName -Encoding UTF8
    $issues = [System.Collections.Generic.List[string]]::new()

    # Helper: extract first capture group
    function Get-Match([string]$pat) {
        $m = [regex]::Match($content, $pat, 'IgnoreCase, Singleline')
        if ($m.Success) { return $m.Groups[1].Value.Trim() }
        return $null
    }

    # 10. <html lang="en">
    if ($content -notmatch '<html\s+lang="en"') {
        $issues.Add('html lang="en" missing')
    }

    # 1. <title>
    $title = Get-Match '<title>([^<]*)</title>'
    if (-not $title) {
        $issues.Add('title missing')
    } else {
        if ($title -notmatch '\| Toolzspan Blog$') {
            $issues.Add("title does not end with ' | Toolzspan Blog': '$title'")
        }
        if ($title -match '\b2026\b') {
            $issues.Add("title contains 2026: '$title'")
        }
        if ($title.Length -lt 30 -or $title.Length -gt 70) {
            $issues.Add("title length $($title.Length) outside 30-70 range: '$title'")
        }
    }

    # 2. meta description
    $metaDesc = Get-Match '<meta\s+name="description"\s+content="([^"]*)"'
    if (-not $metaDesc) {
        $issues.Add('meta description missing')
    } else {
        if ($metaDesc -match '\b2026\b') {
            $issues.Add("meta description contains 2026: '$metaDesc'")
        }
        if ($metaDesc.Length -lt 100 -or $metaDesc.Length -gt 180) {
            $issues.Add("meta description length $($metaDesc.Length) outside 100-180 range")
        }
    }

    # 3. canonical
    $canonical = Get-Match '<link\s+rel="canonical"\s+href="([^"]*)"'
    if (-not $canonical) {
        $issues.Add('canonical missing')
    } else {
        if ($canonical -notmatch '^https://') {
            $issues.Add("canonical not HTTPS: $canonical")
        }
        if ($canonical -notmatch [regex]::Escape($f.Name) + '$') {
            $issues.Add("canonical does not match filename. canonical=$canonical file=$($f.Name)")
        }
    }

    # 4. OG tags
    $ogTitle       = Get-Match '<meta\s+property="og:title"\s+content="([^"]*)"'
    $ogDesc        = Get-Match '<meta\s+property="og:description"\s+content="([^"]*)"'
    $ogUrl         = Get-Match '<meta\s+property="og:url"\s+content="([^"]*)"'
    $ogType        = Get-Match '<meta\s+property="og:type"\s+content="([^"]*)"'
    $ogSiteName    = Get-Match '<meta\s+property="og:site_name"\s+content="([^"]*)"'

    if (-not $ogTitle)    { $issues.Add('og:title missing') }
    if (-not $ogDesc)     { $issues.Add('og:description missing') }
    if (-not $ogUrl)      { $issues.Add('og:url missing') }
    if (-not $ogType)     { $issues.Add('og:type missing') }
    if (-not $ogSiteName) { $issues.Add('og:site_name missing') }

    # 5. OG sync with title/meta
    if ($ogTitle -and $title -and $ogTitle -ne $title) {
        $issues.Add("og:title != title.  og=$ogTitle | title=$title")
    }
    if ($ogDesc -and $metaDesc -and $ogDesc -ne $metaDesc) {
        $issues.Add('og:description != meta description')
    }
    if ($ogUrl -and $canonical -and $ogUrl -ne $canonical) {
        $issues.Add("og:url != canonical.  og=$ogUrl | canonical=$canonical")
    }

    # 6. Twitter
    $twCard  = Get-Match '<meta\s+name="twitter:card"\s+content="([^"]*)"'
    $twTitle = Get-Match '<meta\s+name="twitter:title"\s+content="([^"]*)"'
    $twDesc  = Get-Match '<meta\s+name="twitter:description"\s+content="([^"]*)"'

    if (-not $twCard)  { $issues.Add('twitter:card missing') }
    if (-not $twTitle) { $issues.Add('twitter:title missing') }
    if (-not $twDesc)  { $issues.Add('twitter:description missing') }

    if ($twTitle -and $title -and $twTitle -ne $title) {
        $issues.Add('twitter:title != title')
    }
    if ($twDesc -and $metaDesc -and $twDesc -ne $metaDesc) {
        $issues.Add('twitter:description != meta description')
    }

    # 7. JSON-LD Article - iterate over every <script type="application/ld+json"> block
    $ldBlocks = [regex]::Matches($content, '<script\s+type="application/ld\+json"[^>]*>(.*?)</script>', 'Singleline')
    $articleJson = $null
    foreach ($b in $ldBlocks) {
        $json = $b.Groups[1].Value
        if ($json -match '"@type"\s*:\s*"Article"') {
            $articleJson = $json
            break
        }
    }

    if (-not $articleJson) {
        $issues.Add('JSON-LD Article schema missing')
    } else {
        if ($articleJson -notmatch '"headline"\s*:\s*"[^"]+"')          { $issues.Add('JSON-LD headline missing') }
        if ($articleJson -notmatch '"datePublished"\s*:\s*"[^"]+"')     { $issues.Add('JSON-LD datePublished missing') }
        if ($articleJson -notmatch '"author"\s*:')                      { $issues.Add('JSON-LD author missing') }
        if ($articleJson -notmatch '"publisher"\s*:')                   { $issues.Add('JSON-LD publisher missing') }
        if ($articleJson -notmatch '"mainEntityOfPage"\s*:\s*"[^"]+"')  { $issues.Add('JSON-LD mainEntityOfPage missing') }

        # 8. headline hygiene
        $hl = [regex]::Match($articleJson, '"headline"\s*:\s*"([^"]+)"')
        if ($hl.Success) {
            $headline = $hl.Groups[1].Value
            if ($headline -match '\| Toolzspan Blog') {
                $issues.Add("JSON-LD headline contains ' | Toolzspan Blog' suffix: '$headline'")
            }
            if ($headline -match '\b2026\b') {
                $issues.Add("JSON-LD headline contains 2026: '$headline'")
            }
        }
    }

    # 9. <h1>
    $h1Matches = [regex]::Matches($content, '<h1[^>]*>([^<]*)</h1>', 'IgnoreCase')
    if ($h1Matches.Count -eq 0) {
        $issues.Add('h1 missing')
    } elseif ($h1Matches.Count -gt 1) {
        $issues.Add("multiple h1 tags found ($($h1Matches.Count))")
    } else {
        $h1 = $h1Matches[0].Groups[1].Value.Trim()
        if ($h1 -match '\(2026') {
            $issues.Add("h1 contains (2026: '$h1'")
        }
        if ($h1 -match '\bin 2026\b') {
            $issues.Add("h1 contains 'in 2026': '$h1'")
        }
        if ($h1 -match '2026 Guide') {
            $issues.Add("h1 contains '2026 Guide': '$h1'")
        }
    }

    if ($issues.Count -eq 0) {
        $cleanFiles++
    } else {
        $filesWithIssues++
        $report += [PSCustomObject]@{ File = $f.Name; Issues = $issues }
    }
}

# Print report
Write-Host ''
Write-Host ('Audited {0} blog files.' -f $files.Count) -ForegroundColor Cyan
Write-Host ('Clean: {0}' -f $cleanFiles) -ForegroundColor Green
Write-Host ('With issues: {0}' -f $filesWithIssues) -ForegroundColor $(if ($filesWithIssues -gt 0) { 'Yellow' } else { 'Green' })
Write-Host ''

if ($filesWithIssues -gt 0) {
    foreach ($r in $report) {
        Write-Host ('--- {0}' -f $r.File) -ForegroundColor Yellow
        foreach ($i in $r.Issues) {
            Write-Host ('   * {0}' -f $i) -ForegroundColor DarkYellow
        }
    }
}

Write-Host ''
Write-Host 'Done.' -ForegroundColor Cyan
