$root = "c:\GravityProject\toolzspan.site"
Write-Output "========== VERIFICATION AUDIT =========="

# 1. Contact form
Write-Output "`n--- Contact Form ---"
$c = [System.IO.File]::ReadAllText("$root\contact.html")
if ($c -match 'action=') { Write-Output "  OK: form has action" } else { Write-Output "  FAIL: no action" }
if ($c -match 'method=') { Write-Output "  OK: form has method" } else { Write-Output "  FAIL: no method" }
if ($c -match 'fetch\(') { Write-Output "  OK: AJAX handler present" } else { Write-Output "  FAIL: no AJAX" }

# 2. Trim audio exists
Write-Output "`n--- Trim Audio Tool ---"
if (Test-Path "$root\tools\trim-audio.html") { Write-Output "  OK: trim-audio.html exists" } else { Write-Output "  FAIL: missing" }

# 3. Broken renamed links
Write-Output "`n--- Renamed File Links ---"
$old = @('add-watermark-to-pdf.html','add-password-to-pdf.html','remove-password-from-pdf.html','pptx-to-pdf.html')
$allHtml = Get-ChildItem "$root" -Recurse -Filter "*.html"
$broken = 0
foreach ($f in $allHtml) {
  $txt = [System.IO.File]::ReadAllText($f.FullName)
  foreach ($o in $old) {
    if ($txt.Contains($o)) { Write-Output "  FAIL: $($f.Name) still has $o"; $broken++ }
  }
}
if ($broken -eq 0) { Write-Output "  OK: No broken renamed links" }

# 4. Sitemap
Write-Output "`n--- Sitemap ---"
$sm = [System.IO.File]::ReadAllText("$root\sitemap.xml")
@('add-watermark-pdf.html','add-password-pdf.html','remove-password-pdf.html','trim-audio.html') | ForEach-Object {
  if ($sm -match [regex]::Escape($_)) { Write-Output "  OK: $_ in sitemap" } else { Write-Output "  FAIL: $_ missing from sitemap" }
}
foreach ($o in $old) {
  if ($sm -match [regex]::Escape($o)) { Write-Output "  FAIL: Ghost URL $o still in sitemap" }
}

# 5. Mobile JS
Write-Output "`n--- Mobile Menu JS ---"
$js = [System.IO.File]::ReadAllText("$root\js\main.js")
if ($js -match 'resize') { Write-Output "  OK: resize handler present" } else { Write-Output "  FAIL: no resize" }

# 6. Font check
Write-Output "`n--- Font Loading ---"
$fontBad = 0
foreach ($f in $allHtml) {
  $txt = [System.IO.File]::ReadAllText($f.FullName)
  if ($txt -match 'Playfair' -and $txt -notmatch 'Space\+Grotesk') { $fontBad++; Write-Output "  FAIL: $($f.Name) still has Playfair" }
}
if ($fontBad -eq 0) { Write-Output "  OK: All pages use correct fonts" }

# 7. Blog related posts
Write-Output "`n--- Blog Related Posts ---"
$missing = 0
for ($i = 1; $i -le 22; $i++) {
  $name = "post-{0:D2}.html" -f $i
  $fp = "$root\blog\$name"
  if (Test-Path $fp) {
    $txt = [System.IO.File]::ReadAllText($fp)
    if ($txt -notmatch 'related-posts') { Write-Output "  FAIL: $name missing related posts"; $missing++ }
  }
}
if ($missing -eq 0) { Write-Output "  OK: All 22 old posts have related posts" }

# 8. Search.js
Write-Output "`n--- Search Index ---"
$sjs = [System.IO.File]::ReadAllText("$root\js\search.js")
if ($sjs -match 'trim-audio') { Write-Output "  OK: Trim Audio in search index" } else { Write-Output "  FAIL: Trim Audio missing from search" }
if ($sjs -match '50 tools') { Write-Output "  OK: Search says 50 tools" } else { Write-Output "  FAIL: Search still says 49" }

# 9. pdf-to-word search.js
Write-Output "`n--- pdf-to-word.html ---"
$ptw = [System.IO.File]::ReadAllText("$root\tools\pdf-to-word.html")
if ($ptw -match 'search\.js') { Write-Output "  OK: search.js included" } else { Write-Output "  FAIL: search.js missing" }

# 10. Blog post
Write-Output "`n--- Blog Post ---"
if (Test-Path "$root\blog\how-to-trim-audio-online-free.html") { 
  $bp = [System.IO.File]::ReadAllText("$root\blog\how-to-trim-audio-online-free.html")
  $textOnly = $bp -replace '<[^>]+>', '' -replace '&[a-z]+;', ' ' -replace '\s+', ' '
  $wc = ($textOnly.Trim() -split '\s+').Count
  Write-Output "  OK: Blog post exists ($wc words)"
  if ($bp -match '/tools/trim-audio') { Write-Output "  OK: Internal links to trim-audio tool" } else { Write-Output "  FAIL: No internal link" }
  if ($bp -match 'related-posts') { Write-Output "  OK: Has related posts" } else { Write-Output "  FAIL: No related posts" }
  if ($bp -match 'faq-item') { Write-Output "  OK: Has FAQ" } else { Write-Output "  FAIL: No FAQ" }
} else { Write-Output "  FAIL: Blog post doesn't exist" }

# 11. Blog index
Write-Output "`n--- Blog Index ---"
$bi = [System.IO.File]::ReadAllText("$root\blog\index.html")
if ($bi -match 'how-to-trim-audio') { Write-Output "  OK: Trim Audio blog card in index" } else { Write-Output "  FAIL: Missing from blog index" }

# 12. Tool count
Write-Output "`n--- Tool Count ---"
$toolCount = (Get-ChildItem "$root\tools\*.html" | Where-Object { $_.Name -ne "all-tools.html" }).Count
Write-Output "  Actual tool files: $toolCount"

Write-Output "`n========== AUDIT COMPLETE =========="
