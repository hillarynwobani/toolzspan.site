# Phase C2: Remove inline menuToggle handlers from tool pages
# These conflict with the new drill-down logic in main.js (double-toggle bug).
# main.js already binds the click handler properly.

$ErrorActionPreference = 'Stop'
$toolsDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools'

$updated = 0
Get-ChildItem -Path $toolsDir -Filter '*.html' | ForEach-Object {
  $path = $_.FullName
  $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $original = $content

  # Match the inline handler with whitespace variations
  $pattern = '\s*document\.getElementById\([''"]menuToggle[''"]\)\.addEventListener\([''"]click[''"]\s*,\s*function\s*\(\s*\)\s*\{\s*document\.getElementById\([''"]navMenu[''"]\)\.classList\.toggle\([''"]active[''"]\)\s*;?\s*\}\s*\)\s*;?'
  $content = [regex]::Replace($content, $pattern, '')

  # Also clean up empty <script>...</script> blocks that may now be empty
  $content = [regex]::Replace($content, '<script>\s*</script>', '')

  if ($content -ne $original) {
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
    $updated++
    Write-Host "  Cleaned: $($_.Name)"
  }
}

Write-Host ""
Write-Host "Updated: $updated tool page(s)"
