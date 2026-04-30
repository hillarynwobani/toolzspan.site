# Fix pdf-to-word.html — remove duplicated script block
$fp = "c:\GravityProject\toolzspan.site\tools\pdf-to-word.html"
$content = [System.IO.File]::ReadAllText($fp)

# Find the second occurrence of "</footer>" and remove everything from there to the end
# Then re-append the correct ending
$firstFooterEnd = $content.IndexOf('</footer>') + '</footer>'.Length

# Check if there's a second footer
$secondFooter = $content.IndexOf('</footer>', $firstFooterEnd)
if ($secondFooter -ge 0) {
    # Remove from second footer to end
    $content = $content.Substring(0, $secondFooter)
    # The content now ends mid-script. We need to find where the first script block should end
}

# More robust approach: find the first </footer> and the correct script block after it
# Split at first </footer>
$idx = $content.IndexOf('</footer>')
$beforeFooter = $content.Substring(0, $idx + '</footer>'.Length)

# Now find the FIRST <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js after the footer
$afterFooter = $content.Substring($idx + '</footer>'.Length)

# Find only the first complete script block (pdf.js include + inline script)
$pdfJsIdx = $afterFooter.IndexOf('<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js')
$scriptEnd = $afterFooter.IndexOf('</script>', $pdfJsIdx)
# Find the INLINE script
$inlineStart = $afterFooter.IndexOf('<script>', $scriptEnd)
$inlineEnd = $afterFooter.IndexOf('</script>', $inlineStart)

# Get only the first script block
$firstScriptBlock = $afterFooter.Substring($pdfJsIdx, $inlineEnd + '</script>'.Length - $pdfJsIdx)

# Rebuild
$result = $beforeFooter + "`r`n  " + $firstScriptBlock + "`r`n  <script src=`"../js/main.js`"></script>`r`n  <script src=`"../js/search.js`"></script>`r`n</body>`r`n</html>"

[System.IO.File]::WriteAllText($fp, $result, [System.Text.Encoding]::UTF8)
Write-Output "Fixed pdf-to-word.html"
Write-Output "Lines: $($result.Split("`n").Count)"

# Verify
$check = [System.IO.File]::ReadAllText($fp)
$searchCount = ([regex]::Matches($check, 'search\.js')).Count
$footerCount = ([regex]::Matches($check, 'site-footer')).Count
$extractCount = ([regex]::Matches($check, 'extractStructuredText')).Count
Write-Output "search.js refs: $searchCount"
Write-Output "footer refs: $footerCount" 
Write-Output "extractStructuredText refs: $extractCount"
