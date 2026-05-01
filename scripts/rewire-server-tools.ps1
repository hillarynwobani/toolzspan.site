# Phase D1 continuation: Rewire the 14 FFmpeg-based tool pages to call their
# Netlify function instead of running FFmpeg.wasm / client libs in the browser.
#
# Per-tool config controls which fields the page posts and whether the page needs
# an extra options-field UI snippet injected.

$ErrorActionPreference = 'Stop'
$toolsDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools'

# Config per tool
# endpoint - Netlify function name (no extension)
# outExt   - default output extension (for filename)
# fieldsJs - extra JS object literal for form fields (e.g. '{ bitrate: document.getElementById("bitrateSel").value }')
# optionsHtml - HTML snippet to inject BEFORE uploadArea (e.g. a bitrate select). Empty string if none.
$configs = @{
  'wav-to-mp3.html'       = @{ endpoint='wav-to-mp3';       outExt='mp3'; fieldsJs='{}'; optionsHtml='' }
  'ogg-to-mp3.html'       = @{ endpoint='ogg-to-mp3';       outExt='mp3'; fieldsJs='{}'; optionsHtml='' }
  'mp4-to-mp3.html'       = @{ endpoint='mp4-to-mp3';       outExt='mp3'; fieldsJs='{}'; optionsHtml='' }
  'avi-to-mp4.html'       = @{ endpoint='avi-to-mp4';       outExt='mp4'; fieldsJs='{}'; optionsHtml='' }
  'mov-to-mp4.html'       = @{ endpoint='mov-to-mp4';       outExt='mp4'; fieldsJs='{}'; optionsHtml='' }
  'webm-to-mp4.html'      = @{ endpoint='webm-to-mp4';      outExt='mp4'; fieldsJs='{}'; optionsHtml='' }
  'mp4-converter.html'    = @{ endpoint='mp4-converter';    outExt='mp4'; fieldsJs='{}'; optionsHtml='' }
  'mp3-to-mp4.html'       = @{ endpoint='mp3-to-mp4';       outExt='mp4'; fieldsJs='{}'; optionsHtml='' }

  'compress-mp3.html'     = @{ endpoint='compress-mp3';     outExt='mp3'
    fieldsJs = '{ bitrate: document.getElementById("bitrateSel") ? document.getElementById("bitrateSel").value : "96k" }'
    optionsHtml = @'
<div class="tool-options" style="margin-bottom:14px;">
  <label style="display:block; font-weight:600; margin-bottom:6px; font-size:14px; color:var(--deep-navy);">Target bitrate (lower = smaller file)</label>
  <select id="bitrateSel" style="width:100%; padding:12px 14px; border:1px solid var(--border); border-radius:8px; font-size:15px; background:#fff;">
    <option value="64k">64 kbps (smallest)</option>
    <option value="96k" selected>96 kbps (recommended)</option>
    <option value="128k">128 kbps (good quality)</option>
    <option value="160k">160 kbps</option>
    <option value="192k">192 kbps (high quality)</option>
  </select>
</div>
'@
  }

  'audio-compressor.html' = @{ endpoint='audio-compressor'; outExt='mp3'
    fieldsJs = '{ bitrate: document.getElementById("bitrateSel") ? document.getElementById("bitrateSel").value : "128k" }'
    optionsHtml = @'
<div class="tool-options" style="margin-bottom:14px;">
  <label style="display:block; font-weight:600; margin-bottom:6px; font-size:14px; color:var(--deep-navy);">Output bitrate</label>
  <select id="bitrateSel" style="width:100%; padding:12px 14px; border:1px solid var(--border); border-radius:8px; font-size:15px; background:#fff;">
    <option value="64k">64 kbps (smallest)</option>
    <option value="96k">96 kbps</option>
    <option value="128k" selected>128 kbps (recommended)</option>
    <option value="160k">160 kbps</option>
    <option value="192k">192 kbps (high quality)</option>
  </select>
</div>
'@
  }

  'compress-mp4.html'     = @{ endpoint='compress-mp4';     outExt='mp4'
    fieldsJs = '{ crf: document.getElementById("crfSel") ? document.getElementById("crfSel").value : "28" }'
    optionsHtml = @'
<div class="tool-options" style="margin-bottom:14px;">
  <label style="display:block; font-weight:600; margin-bottom:6px; font-size:14px; color:var(--deep-navy);">Compression level (higher = smaller file, lower quality)</label>
  <select id="crfSel" style="width:100%; padding:12px 14px; border:1px solid var(--border); border-radius:8px; font-size:15px; background:#fff;">
    <option value="20">Low compression (best quality)</option>
    <option value="24">Medium-low</option>
    <option value="28" selected>Balanced (recommended)</option>
    <option value="30">Strong</option>
    <option value="32">Maximum compression</option>
  </select>
</div>
'@
  }

  'video-compressor.html' = @{ endpoint='video-compressor'; outExt='mp4'
    fieldsJs = '{ crf: document.getElementById("crfSel") ? document.getElementById("crfSel").value : "28" }'
    optionsHtml = @'
<div class="tool-options" style="margin-bottom:14px;">
  <label style="display:block; font-weight:600; margin-bottom:6px; font-size:14px; color:var(--deep-navy);">Compression level (higher = smaller file, lower quality)</label>
  <select id="crfSel" style="width:100%; padding:12px 14px; border:1px solid var(--border); border-radius:8px; font-size:15px; background:#fff;">
    <option value="20">Low compression (best quality)</option>
    <option value="24">Medium-low</option>
    <option value="28" selected>Balanced (recommended)</option>
    <option value="30">Strong</option>
    <option value="32">Maximum compression</option>
  </select>
</div>
'@
  }

  'gif-maker.html'        = @{ endpoint='gif-maker';        outExt='gif'
    fieldsJs = '{ width: document.getElementById("gifWidth") ? document.getElementById("gifWidth").value : "480", fps: document.getElementById("gifFps") ? document.getElementById("gifFps").value : "10" }'
    optionsHtml = @'
<div class="tool-options" style="display:flex; gap:12px; margin-bottom:14px; flex-wrap:wrap;">
  <label style="flex:1; min-width:120px;">
    <span style="display:block; font-weight:600; margin-bottom:6px; font-size:14px; color:var(--deep-navy);">Width (px)</span>
    <input type="number" id="gifWidth" value="480" min="120" max="1280" step="10" style="width:100%; padding:12px 14px; border:1px solid var(--border); border-radius:8px; font-size:15px;">
  </label>
  <label style="flex:1; min-width:120px;">
    <span style="display:block; font-weight:600; margin-bottom:6px; font-size:14px; color:var(--deep-navy);">Frame rate (fps)</span>
    <input type="number" id="gifFps" value="10" min="5" max="24" step="1" style="width:100%; padding:12px 14px; border:1px solid var(--border); border-radius:8px; font-size:15px;">
  </label>
</div>
'@
  }

  'gif-converter.html'    = @{ endpoint='gif-converter'
    outExt='mp4'
    fieldsJs = '{ output: document.getElementById("outFmt") ? document.getElementById("outFmt").value : "mp4" }'
    optionsHtml = @'
<div class="tool-options" style="margin-bottom:14px;">
  <label style="display:block; font-weight:600; margin-bottom:6px; font-size:14px; color:var(--deep-navy);">Convert to</label>
  <select id="outFmt" style="width:100%; padding:12px 14px; border:1px solid var(--border); border-radius:8px; font-size:15px; background:#fff;">
    <option value="mp4" selected>MP4 (smaller, faster to load)</option>
    <option value="gif">GIF (animated image)</option>
  </select>
</div>
'@
  }
}

# Inline script template — replaced placeholders at write time
$scriptTemplate = @'
<script src="../js/main.js"></script>
<script src="../js/search.js"></script>
<script src="../js/server-tool.js"></script>
<script>
(function () {
  var fi = document.getElementById('fileInput');
  var ua = document.getElementById('uploadArea');
  var pb = document.getElementById('processBtn');
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

  # 1) Build new inline script
  $newScript = $scriptTemplate
  $newScript = $newScript.Replace('__ENDPOINT__', $cfg.endpoint)
  $newScript = $newScript.Replace('__FIELDSJS__', $cfg.fieldsJs)
  $newScript = $newScript.Replace('__OUTEXT__', $cfg.outExt)

  # 2) Find and replace everything from first <script src or <script> inside <body> after </main>
  # Strategy: find the first <script ...> that appears after </main>, and replace everything
  # from there to </body> with our new block.
  $mainEndIdx = $content.IndexOf('</main>')
  if ($mainEndIdx -lt 0) { $failed += "$fileName (no </main>)"; continue }

  # Find footer first, then everything after footer's closing </footer>
  $footerEndIdx = $content.IndexOf('</footer>', $mainEndIdx)
  if ($footerEndIdx -lt 0) { $failed += "$fileName (no </footer>)"; continue }
  $searchFrom = $footerEndIdx + 9  # after </footer>

  $bodyEndIdx = $content.LastIndexOf('</body>')
  if ($bodyEndIdx -lt 0) { $failed += "$fileName (no </body>)"; continue }

  # Replace the block between (after </footer>) and (before </body>) with our new script
  $before = $content.Substring(0, $searchFrom)
  $after = $content.Substring($bodyEndIdx)
  $content = $before + "`r`n  " + $newScript + "`r`n" + $after

  # 3) Inject options HTML before uploadArea if provided and not already present
  if ($cfg.optionsHtml -and $cfg.optionsHtml.Length -gt 0 -and -not $content.Contains('class="tool-options"')) {
    # Find the uploadArea opening div. Use a non-greedy string search.
    $anchor = '<div class="upload-area" id="uploadArea"'
    $idx = $content.IndexOf($anchor)
    if ($idx -lt 0) {
      # Try class-before-id variant
      $anchor2 = 'id="uploadArea"'
      $idx2 = $content.IndexOf($anchor2)
      if ($idx2 -ge 0) {
        # Walk backward to find the opening `<div`
        $openIdx = $content.LastIndexOf('<div', $idx2)
        if ($openIdx -ge 0) { $idx = $openIdx }
      }
    }
    if ($idx -ge 0) {
      # Walk back to the start of the line for cleaner insertion
      $lineStart = $content.LastIndexOf("`n", $idx)
      if ($lineStart -lt 0) { $lineStart = 0 } else { $lineStart++ }
      $content = $content.Substring(0, $lineStart) + "      " + $cfg.optionsHtml.Trim() + "`r`n" + $content.Substring($lineStart)
    }
  }

  if ($content -ne $original) {
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
    $patched++
    Write-Host "  Patched: $fileName"
  }
}

Write-Host ""
Write-Host "Patched $patched tool page(s)"
if ($failed.Count -gt 0) { Write-Host "Failed: $($failed -join '; ')" }
