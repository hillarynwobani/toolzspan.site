$root = "c:\GravityProject\toolzspan.site"

# Read audio-compressor as template for header/footer/mega-menu
$template = [System.IO.File]::ReadAllText("$root\tools\audio-compressor.html")

# Extract header (lines from <!DOCTYPE> to </header>)
$headerEnd = $template.IndexOf('</header>') + '</header>'.Length
$headerBlock = $template.Substring(0, $headerEnd)

# Extract footer block
$footerStart = $template.IndexOf('<footer')
$footerBlock = $template.Substring($footerStart)

# Replace the head section for trim-audio
$head = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"><link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trim Audio Online Free — Cut MP3, WAV, OGG | Toolzspan</title>
  <meta name="description" content="Trim and cut audio files online for free. Visual waveform editor with drag handles. Supports MP3, WAV, OGG, M4A, AAC. No upload, 100% browser-based.">
  <link rel="canonical" href="https://toolzspan.site/tools/trim-audio.html">
  <meta property="og:title" content="Trim Audio Online Free — Cut MP3, WAV, OGG | Toolzspan"><meta property="og:description" content="Trim and cut audio files online for free. Visual waveform editor with drag handles. No upload required."><meta property="og:url" content="https://toolzspan.site/tools/trim-audio.html"><meta property="og:type" content="website"><meta property="og:site_name" content="Toolzspan">
  <meta name="twitter:card" content="summary_large_image"><meta name="twitter:title" content="Trim Audio Online Free — Cut MP3, WAV, OGG | Toolzspan"><meta name="twitter:description" content="Trim and cut audio files online for free. Visual waveform editor with drag handles. No upload required.">
  <link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Space+Grotesk:wght@600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/style.css">
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"SoftwareApplication","name":"Trim Audio","applicationCategory":"UtilitiesApplication","operatingSystem":"Web","offers":{"@type":"Offer","price":"0","priceCurrency":"USD"},"description":"Trim and cut audio files online for free with a visual waveform editor. Supports MP3, WAV, OGG, M4A, AAC.","url":"https://toolzspan.site/tools/trim-audio.html"}</script>
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"Home","item":"https://toolzspan.site"},{"@type":"ListItem","position":2,"name":"General Tools","item":"https://toolzspan.site/tools/all-tools.html#general"},{"@type":"ListItem","position":3,"name":"Trim Audio","item":"https://toolzspan.site/tools/trim-audio.html"}]}</script>
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[{"@type":"Question","name":"What audio formats can I trim?","acceptedAnswer":{"@type":"Answer","text":"You can trim MP3, WAV, OGG, M4A, and AAC files. The output is always a high-quality WAV file."}},{"@type":"Question","name":"Is there a file size limit?","acceptedAnswer":{"@type":"Answer","text":"Yes, the maximum file size is 50MB. This covers most audio files including full podcast episodes and songs."}},{"@type":"Question","name":"Are my files uploaded to a server?","acceptedAnswer":{"@type":"Answer","text":"No. All processing happens 100% in your browser using the Web Audio API. Your files never leave your device."}},{"@type":"Question","name":"Can I preview the selection before trimming?","acceptedAnswer":{"@type":"Answer","text":"Yes. Click the Play Region button to hear only the selected portion before you trim. You can adjust the start and end handles until you are satisfied."}}]}</script>
  <script src="https://unpkg.com/wavesurfer.js@7/dist/wavesurfer.esm.js" type="module"></script>
  <script src="https://unpkg.com/wavesurfer.js@7/dist/plugins/regions.esm.js" type="module"></script>
  <style>
    .waveform-wrap{background:var(--light-bg);border-radius:12px;padding:20px;margin:20px 0;border:1px solid var(--border);}
    #waveform{min-height:128px;cursor:crosshair;}
    .trim-controls{display:flex;align-items:center;gap:16px;flex-wrap:wrap;margin:16px 0;}
    .trim-controls .time-field{display:flex;flex-direction:column;gap:4px;}
    .trim-controls .time-field label{font-size:12px;font-weight:600;text-transform:uppercase;color:var(--muted);letter-spacing:0.05em;}
    .trim-controls .time-field span{font-size:18px;font-weight:700;color:var(--deep-navy);font-family:'DM Sans',sans-serif;}
    .trim-controls .btn{margin-left:auto;}
    .btn-play-region{background:var(--deep-navy);color:#fff;border:none;padding:10px 20px;border-radius:8px;font-weight:600;cursor:pointer;transition:background 0.2s;}
    .btn-play-region:hover{background:var(--primary-blue);}
    .btn-play-region.playing{background:#e74c3c;}
    @media(max-width:480px){.trim-controls{flex-direction:column;align-items:flex-start;}.trim-controls .btn{margin-left:0;width:100%;}}
  </style>
</head>
'@

# Extract everything between </head> and <main> from template (the header/nav)
$bodyStart = $template.IndexOf('<body>')
$mainStart = $template.IndexOf('<main>')
$navBlock = $template.Substring($bodyStart, $mainStart - $bodyStart)

# Build main content
$mainContent = @'
<main>
    <div class="breadcrumb"><a href="/">Home</a><span>&rsaquo;</span><a href="all-tools.html#general">General Tools</a><span>&rsaquo;</span>Trim Audio</div>
    <section class="tool-hero"><h1>Trim Audio</h1><p>Cut and trim audio files online for free. Visual waveform editor with drag handles. Supports MP3, WAV, OGG, M4A, AAC. No upload &mdash; 100% browser-based.</p></section>
    <div class="ad-slot" id="ad-tool-top"><!-- AdSense --></div>
    <div class="tool-workspace">
<div class="upload-area" id="uploadArea"><div class="upload-area-icon">&#9986;</div>
<p><strong>Drag and drop your audio file here</strong></p><p>or click to browse &bull; MP3, WAV, OGG, M4A, AAC &bull; Max 50MB</p>
<input type="file" id="fileInput" accept=".mp3,.wav,.ogg,.m4a,.aac,.flac"></div>
<div class="file-warning" id="fileWarning"></div><div class="file-error" id="fileError"></div>
<div class="processing-msg" id="processingMsg"><span class="spinner"></span> Loading audio waveform... Please wait.</div>
<div class="file-list" id="fileList"></div>
<div class="waveform-wrap" id="waveformWrap" style="display:none;">
  <div id="waveform"></div>
  <div class="trim-controls">
    <div class="time-field"><label>Start</label><span id="startTime">0:00.000</span></div>
    <div class="time-field"><label>End</label><span id="endTime">0:00.000</span></div>
    <div class="time-field"><label>Duration</label><span id="durTime">0:00.000</span></div>
    <button class="btn-play-region" id="playRegionBtn">&#9654; Play Region</button>
  </div>
</div>
<button class="btn btn-primary btn-block" id="processBtn" disabled>&#9986; Trim Audio</button>
<div class="progress-wrap" id="progressWrap"><div class="progress-bar"><div class="progress-bar-fill" id="progressFill"></div></div><p class="progress-text" id="progressText">Processing...</p></div>
<div class="result-area" id="resultArea"><h3>Done!</h3><p id="resultInfo"></p><button class="btn btn-download" id="downloadBtn">Download Trimmed Audio</button></div>
<p class="no-signup-note"><strong>No sign-up required.</strong> All processing happens in your browser. Your files never leave your device.</p>
<div class="related-tools"><h3>Related Tools</h3><div class="related-tools-grid"><a href="audio-compressor.html" class="related-tool-link">Audio Compressor</a><a href="mp3-converter.html" class="related-tool-link">MP3 Converter</a><a href="mp4-to-mp3.html" class="related-tool-link">MP4 to MP3</a></div></div></div>
    <div class="tool-info-section">
      <h2>How to Use Trim Audio</h2>
      <ol><li>Click the upload area or drag and drop your audio file (MP3, WAV, OGG, M4A, or AAC).</li><li>Wait for the waveform to load &mdash; you will see a visual representation of your audio.</li><li>Drag the blue region handles to select the portion you want to keep.</li><li>Click &ldquo;Play Region&rdquo; to preview your selection before trimming.</li><li>Click &ldquo;Trim Audio&rdquo; to extract the selected portion and download it as a WAV file.</li></ol>
      <h2>Why Use Trim Audio?</h2>
      <ul><li><strong>Visual Precision</strong> &mdash; See your audio waveform and select exactly the right section with drag handles.</li><li><strong>100% Private</strong> &mdash; Your audio never leaves your device. Everything is processed locally in your browser.</li><li><strong>Multiple Formats</strong> &mdash; Works with MP3, WAV, OGG, M4A, and AAC files up to 50MB.</li><li><strong>Instant Preview</strong> &mdash; Listen to your selection before trimming to make sure it sounds perfect.</li></ul>
      <h2>Frequently Asked Questions</h2>
      <div class="faq-item"><button class="faq-question">What audio formats can I trim?</button><div class="faq-answer"><p>You can trim MP3, WAV, OGG, M4A, and AAC files. The output is always a high-quality WAV file.</p></div></div>
      <div class="faq-item"><button class="faq-question">Is there a file size limit?</button><div class="faq-answer"><p>Yes, the maximum file size is 50MB. This covers most audio files including full podcast episodes and songs.</p></div></div>
      <div class="faq-item"><button class="faq-question">Are my files uploaded to a server?</button><div class="faq-answer"><p>No. All processing happens 100% in your browser using the Web Audio API. Your files never leave your device.</p></div></div>
      <div class="faq-item"><button class="faq-question">Can I preview the selection before trimming?</button><div class="faq-answer"><p>Yes. Click the Play Region button to hear only the selected portion before you trim. You can adjust the start and end handles until you are satisfied.</p></div></div>
    
    </div>
    <div class="ad-slot" id="ad-tool-bottom"><!-- AdSense --></div>
  </main>
'@

# Footer from template
$footerStart2 = $template.IndexOf('<footer')
$footerBlock2 = $template.Substring($footerStart2)
# Remove the old script tag from footer block
$footerBlock2 = $footerBlock2 -replace '<script>[\s\S]*?</script>\s*</body>', '</body>'

# Build the trim audio script
$trimScript = @'
  <script src="../js/main.js"></script>
  <script src="../js/search.js"></script>
  <script type="module">
import WaveSurfer from 'https://unpkg.com/wavesurfer.js@7/dist/wavesurfer.esm.js';
import RegionsPlugin from 'https://unpkg.com/wavesurfer.js@7/dist/plugins/regions.esm.js';

var fi=document.getElementById('fileInput'),ua=document.getElementById('uploadArea'),
pb=document.getElementById('processBtn'),pw=document.getElementById('progressWrap'),
pf=document.getElementById('progressFill'),pt=document.getElementById('progressText'),
ra=document.getElementById('resultArea'),ri=document.getElementById('resultInfo'),
db=document.getElementById('downloadBtn'),fw=document.getElementById('fileWarning'),
fe=document.getElementById('fileError'),pm=document.getElementById('processingMsg'),
ww=document.getElementById('waveformWrap'),prb=document.getElementById('playRegionBtn');

var MAX=50,ws=null,regions=null,activeRegion=null,blob=null,fname='',audioBuffer=null,audioCtx=null;

function fmtTime(s){var m=Math.floor(s/60);var ss=Math.floor(s%60);var ms=Math.round((s%1)*1000);return m+':'+String(ss).padStart(2,'0')+'.'+String(ms).padStart(3,'0');}

ua.addEventListener('dragover',function(e){e.preventDefault();ua.classList.add('drag-over');});
ua.addEventListener('dragleave',function(){ua.classList.remove('drag-over');});
ua.addEventListener('drop',function(e){e.preventDefault();ua.classList.remove('drag-over');if(e.dataTransfer.files.length){fi.files=e.dataTransfer.files;handleFile(e.dataTransfer.files[0]);}});
fi.addEventListener('change',function(){if(this.files.length)handleFile(this.files[0]);});

function handleFile(f){
  var mb=f.size/(1024*1024);fname=f.name.replace(/\.[^/.]+$/,'')+'-trimmed.wav';
  if(mb>MAX){fe.textContent='File too large. Maximum size is '+MAX+'MB.';fe.classList.add('active');fw&&fw.classList.remove('active');pb.disabled=true;return;}
  if(mb>MAX*0.75){fw&&(fw.textContent='Large file — waveform may take a moment to load.',fw.classList.add('active'));fe.classList.remove('active');}
  else{fw&&fw.classList.remove('active');fe.classList.remove('active');}
  ra.classList.remove('active');pb.disabled=true;pm.classList.add('active');
  document.getElementById('fileList').innerHTML='<div class=file-item><span class=file-item-name>'+f.name+'</span><span class=file-item-size>'+(mb<1?(f.size/1024).toFixed(1)+' KB':mb.toFixed(2)+' MB')+'</span></div>';
  
  // Decode audio
  var reader=new FileReader();
  reader.onload=function(e){
    audioCtx=new(window.AudioContext||window.webkitAudioContext)();
    audioCtx.decodeAudioData(e.target.result).then(function(buf){
      audioBuffer=buf;
      loadWaveform(f);
    }).catch(function(){
      fe.textContent='Could not decode audio. Please try a different file.';fe.classList.add('active');pm.classList.remove('active');
    });
  };
  reader.readAsArrayBuffer(f);
}

function loadWaveform(f){
  ww.style.display='block';
  if(ws){ws.destroy();}
  regions=RegionsPlugin.create();
  ws=WaveSurfer.create({container:'#waveform',waveColor:'#c5d5f0',progressColor:'#1e6fff',height:128,barWidth:2,barGap:1,barRadius:2,normalize:true,plugins:[regions]});
  ws.loadBlob(f);
  ws.on('ready',function(){
    pm.classList.remove('active');pb.disabled=false;
    var dur=ws.getDuration();
    activeRegion=regions.addRegion({start:0,end:dur,color:'rgba(30,111,255,0.18)',drag:true,resize:true});
    updateTimes(0,dur,dur);
  });
  regions.on('region-updated',function(r){
    var s=r.start,e=r.end;
    updateTimes(s,e,e-s);
  });
}

function updateTimes(s,e,d){
  document.getElementById('startTime').textContent=fmtTime(s);
  document.getElementById('endTime').textContent=fmtTime(e);
  document.getElementById('durTime').textContent=fmtTime(d);
}

var playing=false;
prb.addEventListener('click',function(){
  if(!activeRegion)return;
  if(playing){ws.pause();prb.innerHTML='&#9654; Play Region';prb.classList.remove('playing');playing=false;return;}
  activeRegion.play();prb.innerHTML='&#9724; Stop';prb.classList.add('playing');playing=true;
});
if(ws){ws.on('pause',function(){prb.innerHTML='&#9654; Play Region';prb.classList.remove('playing');playing=false;});}

pb.addEventListener('click',function(){
  if(!audioBuffer||!activeRegion)return;
  pb.disabled=true;pw.classList.add('active');pf.style.width='30%';pt.textContent='Trimming audio...';
  var start=activeRegion.start,end=activeRegion.end,sr=audioBuffer.sampleRate,ch=audioBuffer.numberOfChannels;
  var startSample=Math.floor(start*sr),endSample=Math.floor(end*sr),len=endSample-startSample;
  var offCtx=new OfflineAudioContext(ch,len,sr);
  var newBuf=offCtx.createBuffer(ch,len,sr);
  for(var c=0;c<ch;c++){var src=audioBuffer.getChannelData(c),dst=newBuf.getChannelData(c);for(var i=0;i<len;i++)dst[i]=src[startSample+i];}
  pf.style.width='60%';
  // Encode to WAV
  var wavBuf=encodeWAV(newBuf);
  blob=new Blob([wavBuf],{type:'audio/wav'});
  pf.style.width='100%';pt.textContent='Done!';
  ri.textContent='Trimmed: '+fmtTime(end-start)+' of audio ('+(blob.size/1024).toFixed(1)+' KB)';
  ra.classList.add('active');pb.disabled=false;
});

function encodeWAV(buf){
  var ch=buf.numberOfChannels,sr=buf.sampleRate,len=buf.length;
  var interleaved=new Float32Array(len*ch);
  for(var c=0;c<ch;c++){var d=buf.getChannelData(c);for(var i=0;i<len;i++)interleaved[i*ch+c]=d[i];}
  var dataLen=interleaved.length*2,headerLen=44,totalLen=headerLen+dataLen;
  var ab=new ArrayBuffer(totalLen),v=new DataView(ab);
  function wr(o,s){for(var i=0;i<s.length;i++)v.setUint8(o+i,s.charCodeAt(i));}
  wr(0,'RIFF');v.setUint32(4,totalLen-8,true);wr(8,'WAVE');wr(12,'fmt ');
  v.setUint32(16,16,true);v.setUint16(20,1,true);v.setUint16(22,ch,true);
  v.setUint32(24,sr,true);v.setUint32(28,sr*ch*2,true);v.setUint16(32,ch*2,true);v.setUint16(34,16,true);
  wr(36,'data');v.setUint32(40,dataLen,true);
  var off=44;for(var i=0;i<interleaved.length;i++,off+=2){var s=Math.max(-1,Math.min(1,interleaved[i]));v.setInt16(off,s<0?s*0x8000:s*0x7FFF,true);}
  return ab;
}

db.addEventListener('click',function(){if(!blob)return;var u=URL.createObjectURL(blob),a=document.createElement('a');a.href=u;a.download=fname;a.click();URL.revokeObjectURL(u);});
</script>
'@

# Assemble full page
$fullPage = $head + "`r`n" + $navBlock + "`r`n" + $mainContent + "`r`n"

# Get footer from template (from <footer to </html>)
$fStart = $template.IndexOf('<footer')
$fEnd = $template.IndexOf('</footer>') + '</footer>'.Length
$footer = $template.Substring($fStart, $fEnd - $fStart)

$fullPage += $footer + "`r`n" + $trimScript + "`r`n</body>`r`n</html>"

[System.IO.File]::WriteAllText("$root\tools\trim-audio.html", $fullPage, [System.Text.Encoding]::UTF8)
Write-Output "Created trim-audio.html"
