# fix-header-bugs.ps1
$rootPath = "c:\GravityProject\toolzspan.site"
$htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse | Where-Object { $_.Name -ne "index.html" }
$totalUpdated = 0

# The standard topbar from index.html
$topbarHtml = '  <div class="topbar">🎉 All tools are <span>100% free</span> — No sign-up required. Your privacy is our priority.</div>'

foreach ($file in $htmlFiles) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $changed = $false

        # Bug 1: Fix Search Div to Button
        $oldDiv = '<div class="search-btn">&#128269;</div>'
        $newBtn = '<button class="search-btn" type="button" aria-label="Open search">🔍</button>'
        if ($content.Contains($oldDiv)) {
            $content = $content.Replace($oldDiv, $newBtn)
            $changed = $true
        }

        # Bug 2: Add Missing Topbar (only if it has a header)
        if ($content.Contains('<header class="site-header">') -and (-not $content.Contains('class="topbar"'))) {
            $headerTag = '<header class="site-header">'
            $content = $content.Replace($headerTag, "$headerTag`r`n$topbarHtml")
            $changed = $true
        }

        if ($changed) {
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
            $totalUpdated++
        }
    } catch {
        Write-Host "Skip error in $($file.Name)"
    }
}

Write-Host "Updated $totalUpdated files with header and search button fixes."
