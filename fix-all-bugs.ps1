# =============================================
# TOOLZSPAN MASTER FIX SCRIPT
# Fixes bugs 1, 3, 4, 5, 6, 7, 8, 9
# =============================================

$root = "c:\GravityProject\toolzspan.site"
$fixed = 0

Write-Output "Starting master fix..."

# =============================================
# BUG 1: Contact Form — add action, method, AJAX
# =============================================
Write-Output "=== Fixing Bug 1: Contact Form ==="
$contactPath = "$root\contact.html"
$contact = [System.IO.File]::ReadAllText($contactPath)

# Add action and method to the form tag
$contact = $contact -replace '<form class="contact-form" id="contactForm" novalidate>', '<form class="contact-form" id="contactForm" action="https://api.web3forms.com/submit" method="POST" novalidate>'

# Add AJAX handler script before closing </body>
$contactScript = @'
  <script>
  document.addEventListener('DOMContentLoaded', function() {
    var form = document.getElementById('contactForm');
    var submitBtn = document.getElementById('contactSubmit');
    var successDiv = document.getElementById('contactSuccess');
    var errorDiv = document.getElementById('contactError');
    var errorText = document.getElementById('contactErrorText');

    if (!form) return;

    form.addEventListener('submit', function(e) {
      e.preventDefault();

      // Client-side validation
      var name = document.getElementById('contact-name');
      var email = document.getElementById('contact-email');
      var message = document.getElementById('contact-message');
      var valid = true;

      [name, email, message].forEach(function(el) {
        el.classList.remove('input-error');
        var errEl = el.parentElement.querySelector('.field-error');
        if (errEl) errEl.classList.remove('active');
      });

      if (!name.value.trim()) {
        name.classList.add('input-error');
        document.getElementById('nameError').classList.add('active');
        valid = false;
      }
      if (!email.value.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
        email.classList.add('input-error');
        document.getElementById('emailError').classList.add('active');
        valid = false;
      }
      if (!message.value.trim()) {
        message.classList.add('input-error');
        document.getElementById('messageError').classList.add('active');
        valid = false;
      }
      if (!valid) return;

      submitBtn.classList.add('btn-loading');
      submitBtn.textContent = 'Sending...';
      successDiv.classList.remove('active');
      errorDiv.classList.remove('active');

      var formData = new FormData(form);
      fetch('https://api.web3forms.com/submit', {
        method: 'POST',
        body: formData
      })
      .then(function(res) { return res.json(); })
      .then(function(data) {
        submitBtn.classList.remove('btn-loading');
        submitBtn.textContent = 'Send Message';
        if (data.success) {
          successDiv.classList.add('active');
          form.reset();
        } else {
          errorText.textContent = data.message || 'Something went wrong. Please try again.';
          errorDiv.classList.add('active');
        }
      })
      .catch(function() {
        submitBtn.classList.remove('btn-loading');
        submitBtn.textContent = 'Send Message';
        errorText.textContent = 'Network error. Please check your connection and try again.';
        errorDiv.classList.add('active');
      });
    });
  });
  </script>
'@

$contact = $contact -replace '</body>', "$contactScript`r`n</body>"
[System.IO.File]::WriteAllText($contactPath, $contact, [System.Text.Encoding]::UTF8)
Write-Output "  Fixed contact form"
$fixed++

# =============================================
# BUG 3: Fix broken links to renamed files
# =============================================
Write-Output "=== Fixing Bug 3: Broken internal links ==="
$renameMap = @{
    'add-watermark-to-pdf.html' = 'add-watermark-pdf.html'
    'add-password-to-pdf.html' = 'add-password-pdf.html'
    'remove-password-from-pdf.html' = 'remove-password-pdf.html'
    'pptx-to-pdf.html' = 'powerpoint-to-pdf.html'
}

$allHtmlFiles = Get-ChildItem "$root" -Recurse -Filter "*.html"
foreach ($f in $allHtmlFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    $changed = $false
    foreach ($old in $renameMap.Keys) {
        $new = $renameMap[$old]
        if ($content.Contains($old)) {
            $content = $content.Replace($old, $new)
            $changed = $true
        }
    }
    if ($changed) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Output ("  Fixed renamed links in: " + $f.Name)
        $fixed++
    }
}

# =============================================
# BUG 4: Fix sitemap
# =============================================
Write-Output "=== Fixing Bug 4: Sitemap ==="
$smPath = "$root\sitemap.xml"
$sm = [System.IO.File]::ReadAllText($smPath)

# Replace ghost URLs with correct ones
$sm = $sm -replace 'tools/add-watermark-to-pdf\.html', 'tools/add-watermark-pdf.html'
$sm = $sm -replace 'tools/add-password-to-pdf\.html', 'tools/add-password-pdf.html'
$sm = $sm -replace 'tools/remove-password-from-pdf\.html', 'tools/remove-password-pdf.html'

# Add trim-audio tool entry if not present
if ($sm -notmatch 'trim-audio') {
    $trimEntry = @"

  <url><loc>https://toolzspan.site/tools/trim-audio.html</loc><lastmod>2026-04-30</lastmod><changefreq>monthly</changefreq><priority>0.8</priority></url>
"@
    $sm = $sm -replace '(<!-- General Tools -->)', "`$1$trimEntry"
    # If no comment marker, add before blog section
    if ($sm -notmatch 'trim-audio') {
        $sm = $sm -replace '(\s*<!-- Blog -->)', "$trimEntry`$1"
    }
}

# Add trim audio blog post if not already there
if ($sm -notmatch 'how-to-trim-audio') {
    $blogEntry = "`r`n  <url><loc>https://toolzspan.site/blog/how-to-trim-audio-online-free.html</loc><lastmod>2026-04-30</lastmod><changefreq>monthly</changefreq><priority>0.8</priority></url>"
    $sm = $sm -replace '</urlset>', "$blogEntry`r`n</urlset>"
}

[System.IO.File]::WriteAllText($smPath, $sm, [System.Text.Encoding]::UTF8)
Write-Output "  Fixed sitemap"
$fixed++

# =============================================
# BUG 6: Fix fonts (Playfair -> Space Grotesk)
# =============================================
Write-Output "=== Fixing Bug 6: Font loading ==="
$fontFixed = 0
foreach ($f in $allHtmlFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    if ($content -match 'Playfair' -and $content -notmatch 'Space\+Grotesk') {
        $content = $content -replace 'Playfair\+Display:wght@700;800', 'Space+Grotesk:wght@600;700'
        $content = $content -replace 'Playfair\+Display:wght@700%3B800', 'Space+Grotesk:wght@600;700'
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        $fontFixed++
    }
}
Write-Output "  Fixed fonts on $fontFixed pages"
$fixed += $fontFixed

# =============================================
# BUG 7: Fix garbled em-dash in logo alt text
# =============================================
Write-Output "=== Fixing Bug 7: Logo alt text ==="
$altFixed = 0
foreach ($f in $allHtmlFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    # The garbled text is the UTF-8 bytes for em-dash read as Latin-1
    # It appears as: â€" (3 characters: U+00E2, U+0080, U+0094)
    # We need to match the actual bytes in the file
    $garbled = [char]0x00E2, [char]0x0080, [char]0x0094 -join ''
    $garbled2 = [char]0x00C3, [char]0x00A2, [char]0x00C2, [char]0x0080, [char]0x00C2, [char]0x0094 -join ''
    
    if ($content.Contains($garbled)) {
        $content = $content.Replace($garbled, [char]0x2014)  # proper em-dash
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        $altFixed++
    }
}
# Also try the literal string approach
if ($altFixed -eq 0) {
    foreach ($f in $allHtmlFiles) {
        $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
        if ($text -match 'Toolzspan [^\x20-\x7E]+ All-in-One') {
            # Replace using regex - match garbled chars between "Toolzspan" and "All-in-One"
            $text = [regex]::Replace($text, '(Toolzspan\s*)[^\x20-\x7E]+(\s*All-in-One)', '$1' + [char]0x2014 + ' $2')
            $outBytes = [System.Text.Encoding]::UTF8.GetBytes($text)
            [System.IO.File]::WriteAllBytes($f.FullName, $outBytes)
            $altFixed++
        }
    }
}
Write-Output "  Fixed alt text on $altFixed pages"
$fixed += $altFixed

# =============================================
# BUG 9: Add search.js to pdf-to-word.html
# =============================================
Write-Output "=== Fixing Bug 9: pdf-to-word search.js ==="
$ptwPath = "$root\tools\pdf-to-word.html"
if (Test-Path $ptwPath) {
    $ptw = [System.IO.File]::ReadAllText($ptwPath)
    if ($ptw -notmatch 'search\.js') {
        $ptw = $ptw -replace '(<script src="../js/main\.js"></script>)', '$1' + "`r`n  <script src=`"../js/search.js`"></script>"
        [System.IO.File]::WriteAllText($ptwPath, $ptw, [System.Text.Encoding]::UTF8)
        Write-Output "  Added search.js to pdf-to-word.html"
        $fixed++
    }
}

# =============================================
# BUG 6 (update): Change 49 -> 50 tools tagline
# =============================================
Write-Output "=== Updating tool count 49 -> 50 ==="
$countFixed = 0
foreach ($f in $allHtmlFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    if ($content -match '49 Free Online Tools') {
        $content = $content.Replace('49 Free Online Tools', '50 Free Online Tools')
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        $countFixed++
    }
}
Write-Output "  Updated tool count on $countFixed pages"
$fixed += $countFixed

Write-Output ""
Write-Output "=== MASTER FIX COMPLETE: $fixed items fixed ==="
