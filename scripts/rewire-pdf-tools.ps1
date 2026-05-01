# Phase D1 continuation: Rewire the 6 Office/PDF tool pages to call their Netlify function.
# These use convertBtn / protectBtn / unlockBtn instead of processBtn.
# Password pages keep their existing userPassword/confirmPassword/currentPassword inputs.

$ErrorActionPreference = 'Stop'
$toolsDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools'

# buttonId - the primary action button's id on the page
# outName - filename suffix pattern for the output; JS expression relative to 'selectedFile'
# fieldsJs - JS object literal with form fields
# validateJs - optional JS expression that returns a string error message (and blocks run) or empty string
$configs = @{
  'word-to-pdf.html' = @{
    buttonId='convertBtn'; endpoint='word-to-pdf'; outExt='pdf'; fieldsJs='{}'; validateJs=''
  }
  'excel-to-pdf.html' = @{
    buttonId='convertBtn'; endpoint='excel-to-pdf'; outExt='pdf'; fieldsJs='{}'; validateJs=''
  }
  'powerpoint-to-pdf.html' = @{
    buttonId='convertBtn'; endpoint='powerpoint-to-pdf'; outExt='pdf'; fieldsJs='{}'; validateJs=''
  }
  'pdf-to-word.html' = @{
    buttonId='convertBtn'; endpoint='pdf-to-word'; outExt='docx'; fieldsJs='{}'; validateJs=''
  }
  'add-password-pdf.html' = @{
    buttonId='protectBtn'; endpoint='add-password-pdf'; outExt='pdf'
    fieldsJs = '{ password: document.getElementById("userPassword") ? document.getElementById("userPassword").value : "" }'
    validateJs = @'
(function(){
  var p = document.getElementById("userPassword");
  var c = document.getElementById("confirmPassword");
  if (!p || !p.value) return "Please enter a password.";
  if (c && p.value !== c.value) return "Passwords do not match.";
  if (p.value.length < 4) return "Password must be at least 4 characters.";
  return "";
})()
'@
  }
  'remove-password-pdf.html' = @{
    buttonId='unlockBtn'; endpoint='remove-password-pdf'; outExt='pdf'
    fieldsJs = '{ password: document.getElementById("currentPassword") ? document.getElementById("currentPassword").value : "" }'
    validateJs = @'
(function(){
  var p = document.getElementById("currentPassword");
  if (!p || !p.value) return "Please enter the current password.";
  return "";
})()
'@
  }
}

$scriptTemplate = @'
<script src="../js/main.js"></script>
<script src="../js/search.js"></script>
<script src="../js/server-tool.js"></script>
<script>
(function () {
  var fi = document.getElementById('fileInput');
  var ua = document.getElementById('uploadArea');
  var pb = document.getElementById('__BUTTONID__');
  var ra = document.getElementById('resultArea');
  var ri = document.getElementById('resultInfo');
  var db = document.getElementById('downloadBtn');
  var fl = document.getElementById('fileList');
  var workspace = document.querySelector('.tool-workspace');
  var selectedFile = null, resultBlob = null, resultName = '';

  function formatSize(b) {
    if (b < 1024) return b + ' B';
    if (b < 1048576) return (b / 1024).toFixed(1) + ' KB';
    return (b / 1048576).toFixed(2) + ' MB';
  }
  function handleFile(f) {
    if (!f) return;
    selectedFile = f;
    if (pb) pb.disabled = false;
    if (ra) ra.classList.remove('active');
    if (workspace && window.ToolzspanServer) ToolzspanServer.hideMessages(workspace);
    if (fl) fl.innerHTML = '<div class="file-item"><span class="file-item-name">' + f.name + '</span><span class="file-item-size">' + formatSize(f.size) + '</span></div>';
  }
  if (ua) {
    ua.addEventListener('dragover', function (e) { e.preventDefault(); ua.classList.add('drag-over'); });
    ua.addEventListener('dragleave', function () { ua.classList.remove('drag-over'); });
    ua.addEventListener('drop', function (e) {
      e.preventDefault(); ua.classList.remove('drag-over');
      if (e.dataTransfer.files.length) { fi.files = e.dataTransfer.files; handleFile(e.dataTransfer.files[0]); }
    });
  }
  if (fi) fi.addEventListener('change', function () { if (this.files.length) handleFile(this.files[0]); });

  if (pb) pb.addEventListener('click', async function () {
    if (!selectedFile) return;
    var err = __VALIDATEJS__;
    if (err) { ToolzspanServer.showError(workspace, err); return; }
    pb.disabled = true;
    try {
      var res = await ToolzspanServer.run({
        endpoint: '/.netlify/functions/__ENDPOINT__',
        file: selectedFile,
        fields: __FIELDSJS__,
        container: workspace,
        fallbackName: selectedFile.name.replace(/\.[^.]+$/, '') + '.__OUTEXT__'
      });
      resultBlob = res.blob;
      resultName = res.filename;
      if (ri) ri.textContent = 'Processed: ' + resultName + ' (' + formatSize(resultBlob.size) + ')';
      if (ra) ra.classList.add('active');
    } catch (e) { /* error already displayed */ }
    finally { pb.disabled = false; }
  });

  if (db) db.addEventListener('click', function () {
    if (!resultBlob) return;
    ToolzspanServer.downloadBlob(resultBlob, resultName);
  });
})();
</script>
'@

$patched = 0
$failed = @()

foreach ($fileName in $configs.Keys) {
  $path = Join-Path $toolsDir $fileName
  if (-not (Test-Path $path)) { $failed += "$fileName (not found)"; continue }

  $cfg = $configs[$fileName]
  $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $original = $content

  $newScript = $scriptTemplate
  $newScript = $newScript.Replace('__BUTTONID__', $cfg.buttonId)
  $newScript = $newScript.Replace('__ENDPOINT__', $cfg.endpoint)
  $newScript = $newScript.Replace('__FIELDSJS__', $cfg.fieldsJs)
  $newScript = $newScript.Replace('__OUTEXT__', $cfg.outExt)
  $validate = if ([string]::IsNullOrWhiteSpace($cfg.validateJs)) { '""' } else { $cfg.validateJs.Trim() }
  $newScript = $newScript.Replace('__VALIDATEJS__', $validate)

  $mainEndIdx = $content.IndexOf('</main>')
  if ($mainEndIdx -lt 0) { $failed += "$fileName (no </main>)"; continue }
  $footerEndIdx = $content.IndexOf('</footer>', $mainEndIdx)
  if ($footerEndIdx -lt 0) { $failed += "$fileName (no </footer>)"; continue }
  $searchFrom = $footerEndIdx + 9
  $bodyEndIdx = $content.LastIndexOf('</body>')
  if ($bodyEndIdx -lt 0) { $failed += "$fileName (no </body>)"; continue }

  $before = $content.Substring(0, $searchFrom)
  $after = $content.Substring($bodyEndIdx)
  $content = $before + "`r`n  " + $newScript + "`r`n" + $after

  if ($content -ne $original) {
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
    $patched++
    Write-Host "  Patched: $fileName"
  }
}

Write-Host ""
Write-Host "Patched $patched tool page(s)"
if ($failed.Count -gt 0) { Write-Host "Failed: $($failed -join '; ')" }
