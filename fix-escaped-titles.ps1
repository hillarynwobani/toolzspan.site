#requires -Version 5
$pages = @('add-password-pdf.html','add-watermark-pdf.html','color-picker.html','excel-to-pdf.html','image-compressor.html','image-resizer.html','image-to-pdf.html','ocr-pdf.html','pdf-editor.html','pdf-page-remover.html','pdf-page-rotator.html','pdf-splitter.html','pdf-to-image.html','pdf-to-word.html','powerpoint-to-pdf.html','qr-code-generator.html','remove-password-pdf.html','scan-image.html','sign-pdf.html','word-counter.html','word-to-pdf.html')
$enc = New-Object System.Text.UTF8Encoding($false)
$toolsDir = 'c:\GravityProject\toolzspan.site\tools'
$fixed = 0
foreach ($name in $pages) {
    $path = Join-Path $toolsDir $name
    $c = [IO.File]::ReadAllText($path)
    $newC = $c -replace '\\ ', ' '
    $newC = $newC -replace '\\\|', '|'
    $newC = $newC -replace '\\—', '—'
    if ($newC -ne $c) {
        [IO.File]::WriteAllText($path, $newC, $enc)
        $fixed++
        Write-Host ('Fixed: ' + $name)
    }
}
Write-Host ('Total fixed: ' + $fixed)
