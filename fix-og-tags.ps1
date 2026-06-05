# fix-og-tags.ps1
$rootPath = "c:\GravityProject\toolzspan.site"
$htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse
$updatedCount = 0
$skippedCount = 0

$oldTag = '<meta property="og:image" content="https://toolzspan.site/og-image.png">'
$newTags = '<meta property="og:image" content="https://toolzspan.site/og-image.png">
  <meta property="og:image:width"      content="1200">
  <meta property="og:image:height"     content="630">
  <meta property="og:image:type"       content="image/png">
  <meta property="og:image:alt"        content="Toolzspan - 50+ Free Online Tools">
  <meta property="og:image:secure_url" content="https://toolzspan.site/og-image.png">'

foreach ($file in $htmlFiles) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $changed = $false

        if ($content.Contains($oldTag) -and (-not $content.Contains('og:image:width'))) {
            $content = $content.Replace($oldTag, $newTags)
            $changed = $true
        }

        if ($content.Contains('property="twitter:image"')) {
            $content = $content.Replace('property="twitter:image"', 'name="twitter:image"')
            $changed = $true
        }

        if ($changed) {
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
            $updatedCount++
            Write-Host "Updated: $($file.FullName)"
        } else {
            $skippedCount++
        }
    }
    catch {
        Write-Host "Error in $($file.FullName): $($_.Exception.Message)"
    }
}

Write-Host "Done. Updated: $updatedCount, Skipped: $skippedCount"
