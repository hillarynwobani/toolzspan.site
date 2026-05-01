# Phase E: Retrofit all tool pages with 3 AdSense placements per Section 6D update
# - Top: above tool interface (rename existing ad-tool-top div)
# - Mid: NEW - between tool-workspace and tool-info-section
# - Bottom: at very bottom (rename existing ad-tool-bottom div)
# Each placement gets the full <ins class="adsbygoogle"> template

$ErrorActionPreference = 'Stop'
$toolsDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools'

$adsenseTop = @'
<div class="adsense-placeholder adsense-top">
  <ins class="adsbygoogle"
       style="display:block"
       data-ad-client="ca-pub-XXXXXXXXXXXXXXXX"
       data-ad-slot="XXXXXXXXXX"
       data-ad-format="auto"
       data-full-width-responsive="true"></ins>
  <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>
'@

$adsenseMid = @'
<div class="adsense-placeholder adsense-mid">
  <ins class="adsbygoogle"
       style="display:block"
       data-ad-client="ca-pub-XXXXXXXXXXXXXXXX"
       data-ad-slot="XXXXXXXXXX"
       data-ad-format="auto"
       data-full-width-responsive="true"></ins>
  <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>
'@

$adsenseBottom = @'
<div class="adsense-placeholder adsense-bottom">
  <ins class="adsbygoogle"
       style="display:block"
       data-ad-client="ca-pub-XXXXXXXXXXXXXXXX"
       data-ad-slot="XXXXXXXXXX"
       data-ad-format="auto"
       data-full-width-responsive="true"></ins>
  <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>
'@

$updated = 0
$skipped = 0
Get-ChildItem -Path $toolsDir -Filter '*.html' | ForEach-Object {
  $path = $_.FullName
  # Skip all-tools.html (directory page, no ads)
  if ($_.Name -eq 'all-tools.html') { $skipped++; return }

  $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $original = $content

  # Skip if already retrofitted
  if ($content -match 'adsense-placeholder') {
    $skipped++
    return
  }

  # 1) Replace existing ad-tool-top div with new adsense-top block
  $content = [regex]::Replace($content, '<div class="ad-slot" id="ad-tool-top">[^<]*<!--[^>]*-->[^<]*</div>', $adsenseTop, 'Singleline')
  # Fallback: catch any variation (no comment, etc.)
  $content = [regex]::Replace($content, '<div class="ad-slot" id="ad-tool-top">.*?</div>', $adsenseTop, 'Singleline')

  # 2) Insert mid placement between </div> closing tool-workspace and <div class="tool-info-section">
  # Pattern: </div>\s*<div class="tool-info-section">
  if ($content -match '<div class="tool-info-section"') {
    $content = [regex]::Replace($content, '(</div>\s*)(<div class="tool-info-section")', "</div>`r`n`r`n    $adsenseMid`r`n    `$2", 'Singleline')
  }

  # 3) Replace existing ad-tool-bottom div with new adsense-bottom block
  $content = [regex]::Replace($content, '<div class="ad-slot" id="ad-tool-bottom">[^<]*<!--[^>]*-->[^<]*</div>', $adsenseBottom, 'Singleline')
  $content = [regex]::Replace($content, '<div class="ad-slot" id="ad-tool-bottom">.*?</div>', $adsenseBottom, 'Singleline')

  if ($content -ne $original) {
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
    $updated++
  }
}

Write-Host "Updated: $updated tool page(s)"
Write-Host "Skipped: $skipped (already retrofitted or directory page)"
