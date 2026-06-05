$utf8 = New-Object System.Text.UTF8Encoding($false)
$targetDash = [char]8212  # Clean em-dash
$mangledPart = [char]226 + [char]8364 + [char]8212 # â, €, —

$files = Get-ChildItem -Path "c:\GravityProject\toolzspan.site" -Filter "*.html" -Recurse
foreach ($file in $files) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, $utf8)
        if ($content.Contains($mangledPart)) {
            $content = $content.Replace($mangledPart, $targetDash)
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8)
            Write-Host "Fixed stubborn dash in: $($file.Name)"
        }
    } catch {}
}
