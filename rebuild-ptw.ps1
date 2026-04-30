# Rebuild pdf-to-word.html properly
# Use audio-compressor as template for header/nav/footer, keep existing head/body content

$root = "c:\GravityProject\toolzspan.site"
$template = [System.IO.File]::ReadAllText("$root\tools\audio-compressor.html")

# Extract nav block (from <body> to </header> inclusive)
$bodyIdx = $template.IndexOf('<body>')
$headerEndIdx = $template.IndexOf('</header>') + '</header>'.Length
$navBlock = $template.Substring($bodyIdx, $headerEndIdx - $bodyIdx)

# Extract footer block (from <footer to </footer> inclusive)  
$footerStart = $template.IndexOf('<footer')
$footerEnd = $template.IndexOf('</footer>') + '</footer>'.Length
$footerBlock = $template.Substring($footerStart, $footerEnd - $footerStart)

$head = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PDF to Word — Free Online | Toolzspan</title>
  <meta name="description" content="Convert PDF files to editable Word documents for free. Extract text from your PDFs and download as a .docx file instantly in your browser.">
  <link rel="canonical" href="https://toolzspan.site/tools/pdf-to-word.html">
  <meta property="og:title" content="PDF to Word — Free Online | Toolzspan">
  <meta property="og:description" content="Convert PDF files to editable Word documents for free.">
  <meta property="og:url" content="https://toolzspan.site/tools/pdf-to-word.html">
  <meta property="og:type" content="website">
  <meta property="og:image" content="https://toolzspan.site/og-image.png">
  <meta name="twitter:card" content="summary_large_image">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Space+Grotesk:wght@600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/style.css">
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"SoftwareApplication","name":"PDF to Word","applicationCategory":"UtilitiesApplication","operatingSystem":"Web","offers":{"@type":"Offer","price":"0","priceCurrency":"USD"},"description":"Convert PDF files to editable Word documents for free.","url":"https://toolzspan.site/tools/pdf-to-word.html"}</script>
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"Home","item":"https://toolzspan.site"},{"@type":"ListItem","position":2,"name":"PDF & Documents","item":"https://toolzspan.site/tools/all-tools.html#pdf"},{"@type":"ListItem","position":3,"name":"PDF to Word","item":"https://toolzspan.site/tools/pdf-to-word.html"}]}</script>
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[{"@type":"Question","name":"Is PDF to Word free to use?","acceptedAnswer":{"@type":"Answer","text":"Yes, PDF to Word on Toolzspan is completely free. No sign-up or account required."}},{"@type":"Question","name":"Is my file safe when I use PDF to Word?","acceptedAnswer":{"@type":"Answer","text":"Yes. Your file never leaves your device — all processing happens in your browser."}},{"@type":"Question","name":"What file size can I upload?","acceptedAnswer":{"@type":"Answer","text":"You can upload files up to 50MB for optimal performance in the browser."}},{"@type":"Question","name":"Does PDF to Word work on mobile?","acceptedAnswer":{"@type":"Answer","text":"Yes, PDF to Word works on all devices including mobile phones and tablets. No app download needed."}}]}</script>
</head>
'@

$mainContent = @'
  <main>
    <div class="breadcrumb"><a href="/">Home</a><span>›</span><a href="all-tools.html#pdf">PDF & Documents</a><span>›</span>PDF to Word</div>
    <section class="tool-hero"><h1>PDF to Word</h1><p>Convert your PDF files into editable Word documents. This tool extracts text content from your PDF and creates a downloadable .doc file with preserved paragraph structure.</p></section>
    <div class="ad-slot" id="ad-tool-top"></div>
    <div class="tool-workspace">
      <div class="upload-area" id="uploadArea"><div class="upload-area-icon">📝</div><p><strong>Drag and drop a PDF file here</strong></p><p>or click to browse</p><input type="file" id="fileInput" accept=".pdf"></div>
      <div class="file-list" id="fileList"></div>
      <button class="btn btn-primary btn-block" id="convertBtn" disabled>Convert to Word</button>
      <div class="progress-wrap" id="progressWrap"><div class="progress-bar"><div class="progress-bar-fill" id="progressFill"></div></div><p class="progress-text" id="progressText">Converting...</p></div>
      <div class="result-area" id="resultArea"><h3>Conversion Complete</h3><p id="resultInfo"></p><button class="btn btn-download" id="downloadBtn">Download Word Document</button></div>
      <p class="no-signup-note"><strong>No sign-up required.</strong> Your files never leave your browser.</p>
      <div class="related-tools"><h3>Related Tools</h3><div class="related-tools-grid"><a href="word-to-pdf.html" class="related-tool-link">Word to PDF</a><a href="pdf-editor.html" class="related-tool-link">PDF Editor</a><a href="ocr-pdf.html" class="related-tool-link">OCR PDF</a></div></div>
    </div>
    <div class="tool-info-section">
      <h2>How to Use PDF to Word</h2>
      <ol><li>Upload your PDF file using the area above.</li><li>Click "Convert to Word" to extract text.</li><li>Wait while the PDF pages are processed.</li><li>Download your Word document (.doc) file.</li></ol>
      <h2>Why Use Toolzspan PDF to Word?</h2>
      <ul><li><strong>100% Free</strong> — No hidden fees or limits.</li><li><strong>Fast Processing</strong> — Get your result in seconds.</li><li><strong>Private & Secure</strong> — Your files stay on your device.</li><li><strong>Cross-Platform</strong> — Works seamlessly on desktop, tablet, and mobile.</li></ul>
      <h2>Frequently Asked Questions</h2>
      <div class="faq-item"><button class="faq-question">Is PDF to Word free to use?</button><div class="faq-answer"><p>Yes, PDF to Word on Toolzspan is completely free. No sign-up or account required.</p></div></div>
      <div class="faq-item"><button class="faq-question">Is my file safe when I use PDF to Word?</button><div class="faq-answer"><p>Yes. Your file never leaves your device — all processing happens in your browser.</p></div></div>
      <div class="faq-item"><button class="faq-question">What file size can I upload?</button><div class="faq-answer"><p>You can upload files up to 50MB for optimal performance in the browser.</p></div></div>
      <div class="faq-item"><button class="faq-question">Does PDF to Word work on mobile?</button><div class="faq-answer"><p>Yes, PDF to Word works on all devices including mobile phones and tablets. No app download needed.</p></div></div>
    </div>
    <div class="ad-slot" id="ad-tool-bottom"></div>
  </main>
'@

# The inline conversion script
$script = @'
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
  <script>
    var srcFile=null,resultBlob=null;
    var fileInput=document.getElementById('fileInput'),uploadArea=document.getElementById('uploadArea'),fileList=document.getElementById('fileList'),convertBtn=document.getElementById('convertBtn'),progressWrap=document.getElementById('progressWrap'),progressFill=document.getElementById('progressFill'),progressText=document.getElementById('progressText'),resultArea=document.getElementById('resultArea'),resultInfo=document.getElementById('resultInfo'),downloadBtn=document.getElementById('downloadBtn');
    function formatSize(b){if(b<1024)return b+' B';if(b<1048576)return(b/1024).toFixed(1)+' KB';return(b/1048576).toFixed(2)+' MB';}
    uploadArea.addEventListener('dragover',function(e){e.preventDefault();uploadArea.classList.add('drag-over');});
    uploadArea.addEventListener('dragleave',function(){uploadArea.classList.remove('drag-over');});
    uploadArea.addEventListener('drop',function(e){e.preventDefault();uploadArea.classList.remove('drag-over');var f=Array.from(e.dataTransfer.files).find(function(f){return f.type==='application/pdf';});if(f)loadFile(f);});
    fileInput.addEventListener('change',function(){if(fileInput.files[0])loadFile(fileInput.files[0]);});
    function loadFile(f){srcFile=f;fileList.innerHTML='<div class="file-item"><span class="file-item-name">'+f.name+'</span><span class="file-item-size">'+formatSize(f.size)+'</span></div>';convertBtn.disabled=false;}
    function extractStructuredText(items){if(!items||items.length===0)return[];var lines=[];var cl={text:'',y:null,fontSize:0,x:0};var sorted=items.slice().sort(function(a,b){var ay=a.transform?a.transform[5]:0;var by=b.transform?b.transform[5]:0;if(Math.abs(ay-by)<3){return(a.transform?a.transform[4]:0)-(b.transform?b.transform[4]:0);}return by-ay;});for(var i=0;i<sorted.length;i++){var item=sorted[i];if(!item.str&&item.str!=='')continue;var iy=item.transform?item.transform[5]:0;var ix=item.transform?item.transform[4]:0;var ifs=item.transform?Math.abs(item.transform[3]):12;if(cl.y===null){cl={text:item.str,y:iy,fontSize:ifs,x:ix};}else if(Math.abs(iy-cl.y)<3){if(cl.text.length>0){var lc=cl.text[cl.text.length-1];if(lc!==' '&&item.str&&item.str[0]!==' ')cl.text+=' ';}cl.text+=item.str;}else{if(cl.text.trim())lines.push({text:cl.text.trim(),fontSize:cl.fontSize,y:cl.y,x:cl.x});cl={text:item.str,y:iy,fontSize:ifs,x:ix};}}if(cl.text&&cl.text.trim())lines.push({text:cl.text.trim(),fontSize:cl.fontSize,y:cl.y,x:cl.x});return lines;}
    function groupIntoParagraphs(lines){if(lines.length===0)return[];var paragraphs=[];var cp={lines:[lines[0]],fontSize:lines[0].fontSize};for(var i=1;i<lines.length;i++){var pl=lines[i-1];var cl=lines[i];var lg=Math.abs(pl.y-cl.y);var af=(pl.fontSize+cl.fontSize)/2;var ns=af*1.6;var fc=Math.abs(pl.fontSize-cl.fontSize)>2;var bg=lg>ns*1.3;if(fc||bg){paragraphs.push(cp);cp={lines:[cl],fontSize:cl.fontSize};}else{cp.lines.push(cl);}}paragraphs.push(cp);return paragraphs;}
    convertBtn.addEventListener('click',async function(){if(typeof pdfjsLib==='undefined'){alert('PDF library is still loading.');return;}convertBtn.disabled=true;progressWrap.classList.add('active');resultArea.classList.remove('active');pdfjsLib.GlobalWorkerOptions.workerSrc='https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';try{var ab=await srcFile.arrayBuffer();var pdf=await pdfjsLib.getDocument({data:ab}).promise;var ap=[];for(var p=1;p<=pdf.numPages;p++){progressText.textContent='Extracting page '+p+' of '+pdf.numPages+'...';progressFill.style.width=((p/pdf.numPages)*70)+'%';await new Promise(function(r){setTimeout(r,0);});var page=await pdf.getPage(p);var content=await page.getTextContent();var lines=extractStructuredText(content.items);var paragraphs=groupIntoParagraphs(lines);if(p>1&&ap.length>0)ap.push({lines:[],fontSize:0,isPageBreak:true});paragraphs.forEach(function(para){ap.push(para);});}progressText.textContent='Creating Word document...';progressFill.style.width='85%';var html='<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40"><head><meta charset="utf-8"><title>'+srcFile.name.replace('.pdf','')+'</title><style>body{font-family:Calibri,Arial,sans-serif;font-size:11pt;line-height:1.5;margin:72pt;color:#1a1a1a;}h1{font-size:18pt;font-weight:bold;margin:12pt 0 6pt 0;}h2{font-size:14pt;font-weight:bold;margin:10pt 0 4pt 0;}h3{font-size:12pt;font-weight:bold;margin:8pt 0 4pt 0;}p{font-size:11pt;margin:0 0 6pt 0;text-align:justify;}br.page-break{page-break-before:always;}<\/style><\/head><body>';ap.forEach(function(para){if(para.isPageBreak){html+='<br class="page-break">';return;}var text=para.lines.map(function(l){return l.text;}).join(' ').trim();if(!text)return;text=text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');var fs=para.fontSize||11;if(fs>=18)html+='<h1>'+text+'<\/h1>';else if(fs>=14)html+='<h2>'+text+'<\/h2>';else if(fs>=12.5)html+='<h3>'+text+'<\/h3>';else html+='<p>'+text+'<\/p>';});html+='<\/body><\/html>';resultBlob=new Blob([html],{type:'application/msword'});progressFill.style.width='100%';progressText.textContent='Done!';resultInfo.textContent='Text extracted from '+pdf.numPages+' page(s) with '+ap.filter(function(p){return !p.isPageBreak;}).length+' paragraph(s).';resultArea.classList.add('active');}catch(e){alert('Error converting PDF: '+e.message);progressText.textContent='Error occurred.';}convertBtn.disabled=false;});
    downloadBtn.addEventListener('click',function(){var u=URL.createObjectURL(resultBlob);var a=document.createElement('a');a.href=u;a.download=srcFile.name.replace('.pdf','.doc');a.click();URL.revokeObjectURL(u);});
  </script>
  <script src="../js/main.js"></script>
  <script src="../js/search.js"></script>
</body>
</html>
'@

$fullPage = $head + "`r`n" + $navBlock + "`r`n" + $mainContent + "`r`n" + $footerBlock + "`r`n" + $script

[System.IO.File]::WriteAllText("$root\tools\pdf-to-word.html", $fullPage, [System.Text.Encoding]::UTF8)

# Verify
$check = [System.IO.File]::ReadAllText("$root\tools\pdf-to-word.html")
Write-Output "Rebuilt pdf-to-word.html"
Write-Output "search.js: $(([regex]::Matches($check,'search\.js')).Count)"
Write-Output "extractStructuredText: $(([regex]::Matches($check,'extractStructuredText')).Count)"
Write-Output "site-footer: $(([regex]::Matches($check,'site-footer')).Count)"
