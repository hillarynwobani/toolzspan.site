# strip-2026-year-tags.ps1
# Sweep all blog HTML files to remove "2026" year-padding from titles and body copy,
# while preserving legitimate date references (bylines, JSON-LD datePublished, footer copyright,
# canonical URLs, file names, blog-card-date labels).
#
# Idempotent: running it twice is a no-op.

$ErrorActionPreference = 'Stop'

$blogDir = Join-Path $PSScriptRoot '..\blog'
$blogDir = (Resolve-Path $blogDir).Path

$files = Get-ChildItem -Path $blogDir -Filter '*.html' -File
Write-Host "Scanning $($files.Count) blog files in $blogDir" -ForegroundColor Cyan

# Patterns applied in order. Regex with case-insensitivity where needed.
# IMPORTANT: These must not touch:
#   - "April N, 2026" (byline / card dates)
#   - "2026-04-NN"   (ISO dates in JSON-LD)
#   - "&copy; 2026" / "(c) 2026" (footer)
#   - "-2026.html"   (file names / canonical URLs)
#   - "blog-card-date">April N, 2026<" (index cards)

$patterns = @(
    # 1. " (2026 Guide)" and " (2026)" parenthetical year badges (anywhere, incl. titles/headings)
    @{ Find = '\s*\(2026(?:\s+Guide)?\)'; Replace = ''; Desc = 'strip (2026) / (2026 Guide) parenthetical' }

    # 2. " — Complete Guide (2026)" style is already handled by #1 since we only match the parenthetical

    # 3. "The Complete 2026 Guide" -> "The Complete Guide"
    @{ Find = '\bThe Complete 2026 Guide\b'; Replace = 'The Complete Guide'; Desc = 'strip "The Complete 2026 Guide"' }

    # 4. "2026 Guide" as standalone (no leading "The Complete")
    @{ Find = '\s+2026 Guide\b'; Replace = ' Guide'; Desc = 'strip standalone "2026 Guide"' }

    # 5. "in 2026 Guide" edge case
    @{ Find = '\s+in 2026\s+Guide\b'; Replace = ' Guide'; Desc = 'strip "in 2026 Guide"' }

    # 6. Sentence start: "In 2026, " -> "Today, " (keeps grammar, lowercase safe)
    @{ Find = '(?<=[>\s])In 2026,\s*'; Replace = 'Today, '; Desc = 'rewrite "In 2026, " to "Today, "' }

    # 7. Sentence start lowercase: "in 2026, " -> "today, "
    @{ Find = '(?<=[>\s])in 2026,\s*'; Replace = 'today, '; Desc = 'rewrite "in 2026, " to "today, "' }

    # 8. Mid-sentence " in 2026" -> "" (leading space + "in 2026", lookahead preserves trailing punctuation/whitespace)
    @{ Find = '\sin 2026(?=[\s,\.\-\u2014])'; Replace = ''; Desc = 'strip mid-sentence " in 2026"' }
)

$totalFilesChanged = 0
$totalReplacements = 0

foreach ($f in $files) {
    $content = Get-Content -Raw -LiteralPath $f.FullName
    if ($null -eq $content -or $content.Length -eq 0) { continue }
    $original = $content
    $fileReplacements = 0

    foreach ($p in $patterns) {
        $matches = [regex]::Matches($content, $p.Find)
        if ($matches.Count -gt 0) {
            $content = [regex]::Replace($content, $p.Find, $p.Replace)
            $fileReplacements += $matches.Count
            Write-Host ("  [{0}] {1} x {2}" -f $f.Name, $p.Desc, $matches.Count) -ForegroundColor DarkGray
        }
    }

    if ($content -ne $original) {
        # Write back using UTF-8 without BOM (same as original encoding convention)
        [System.IO.File]::WriteAllText($f.FullName, $content, (New-Object System.Text.UTF8Encoding $false))
        $totalFilesChanged++
        $totalReplacements += $fileReplacements
        Write-Host ("Changed: {0}  ({1} replacements)" -f $f.Name, $fileReplacements) -ForegroundColor Green
    }
}

Write-Host ""
Write-Host ("Done. Files changed: {0}. Total replacements: {1}." -f $totalFilesChanged, $totalReplacements) -ForegroundColor Cyan
