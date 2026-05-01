# add-og-site-name.ps1
# Add <meta property="og:site_name" content="Toolzspan"> to every blog file that
# lacks it. Idempotent: skips files that already have og:site_name.
# Insertion point: right after the og:type line (matching file's existing style/indent).

$ErrorActionPreference = 'Stop'

$blogDir = Join-Path $PSScriptRoot '..\blog'
$blogDir = (Resolve-Path $blogDir).Path

$files = Get-ChildItem -Path $blogDir -Filter '*.html' -File
$changed = 0

foreach ($f in $files) {
    $content = Get-Content -Raw -LiteralPath $f.FullName -Encoding UTF8
    if ($content -match '<meta\s+property="og:site_name"') {
        continue
    }

    # Try to insert after the og:type line, preserving the leading indentation/newline
    # of that line.
    $updated = [regex]::Replace(
        $content,
        '(?<prefix>\r?\n?[ \t]*)<meta\s+property="og:type"\s+content="[^"]*"\s*/?>',
        {
            param($m)
            $original = $m.Value
            $prefix   = $m.Groups['prefix'].Value
            # If prefix has a newline we preserve it; otherwise match inline style (no leading \n)
            return $original + $prefix + '<meta property="og:site_name" content="Toolzspan">'
        },
        'Singleline'
    )

    if ($updated -ne $content) {
        [System.IO.File]::WriteAllText($f.FullName, $updated, (New-Object System.Text.UTF8Encoding $false))
        $changed++
        Write-Host ('Added og:site_name -> {0}' -f $f.Name) -ForegroundColor Green
    } else {
        Write-Host ('SKIPPED (no og:type anchor) -> {0}' -f $f.Name) -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host ('Files changed: {0}' -f $changed) -ForegroundColor Cyan
