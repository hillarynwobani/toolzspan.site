# Sync blog/index.html card titles with new SEO titles (without " | Toolzspan Blog" suffix)
$ErrorActionPreference = 'Stop'
$blogDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'blog'
$indexPath = Join-Path $blogDir 'index.html'

# Build title lookup from each blog file's <title> tag, stripped of " | Toolzspan Blog"
$titleMap = @{}
Get-ChildItem -Path $blogDir -Filter '*.html' | Where-Object { $_.Name -ne 'index.html' } | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  if ($c -match '<title>([^<]+)</title>') {
    $titleMap[$_.Name] = ($matches[1] -replace ' \| Toolzspan Blog$', '')
  }
}

$content = Get-Content $indexPath -Raw -Encoding UTF8
$original = $content
$replacements = 0

foreach ($file in $titleMap.Keys) {
  $newTitle = $titleMap[$file]
  # Pattern: <a href="POST_FILE">CURRENT_TITLE</a>
  $pattern = "(<a href=`"$([regex]::Escape($file))`">)([^<]+)(</a>)"
  $newContent = [regex]::Replace($content, $pattern, {
    param($m)
    "$($m.Groups[1].Value)$newTitle$($m.Groups[3].Value)"
  })
  if ($newContent -ne $content) {
    $count = ([regex]::Matches($content, $pattern)).Count
    $replacements += $count
    $content = $newContent
  }
}

if ($content -ne $original) {
  Set-Content -LiteralPath $indexPath -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Updated blog/index.html with $replacements title replacements."
} else {
  Write-Host "No changes needed."
}
