/* ============================================
   TOOLZSPAN — Smart Search Engine
   Fuzzy matching with keyword aliases
   ============================================ */

(function() {
  'use strict';

  // All 50 tools with keyword aliases for fuzzy matching
  var tools = [
    // PDF Tools
    { name: 'PDF Compressor', url: '/tools/pdf-compressor.html', tags: ['compress', 'shrink', 'reduce', 'smaller', 'size', 'pdf', 'squeeze'], cat: 'PDF', icon: '📄' },
    { name: 'PDF Merger', url: '/tools/pdf-merger.html', tags: ['merge', 'combine', 'join', 'pdf', 'multiple', 'together', 'unite'], cat: 'PDF', icon: '🔗' },
    { name: 'PDF Splitter', url: '/tools/pdf-splitter.html', tags: ['split', 'separate', 'extract', 'pages', 'pdf', 'divide', 'break'], cat: 'PDF', icon: '✂️' },
    { name: 'PDF to Image', url: '/tools/pdf-to-image.html', tags: ['pdf', 'image', 'picture', 'jpg', 'png', 'photo', 'screenshot', 'convert'], cat: 'Convert', icon: '🖼️' },
    { name: 'Image to PDF', url: '/tools/image-to-pdf.html', tags: ['image', 'pdf', 'picture', 'jpg', 'png', 'photo', 'convert', 'scan'], cat: 'Convert', icon: '📸' },
    { name: 'PDF Page Rotator', url: '/tools/pdf-page-rotator.html', tags: ['rotate', 'turn', 'flip', 'orientation', 'landscape', 'portrait', 'pdf', 'page'], cat: 'PDF', icon: '🔄' },
    { name: 'PDF Page Remover', url: '/tools/pdf-page-remover.html', tags: ['remove', 'delete', 'page', 'pdf', 'erase', 'unwanted'], cat: 'PDF', icon: '🗑️' },
    { name: 'PDF Editor', url: '/tools/pdf-editor.html', tags: ['edit', 'modify', 'change', 'text', 'pdf', 'annotate', 'write'], cat: 'PDF', icon: '✏️' },
    { name: 'Add Watermark to PDF', url: '/tools/add-watermark-pdf.html', tags: ['watermark', 'stamp', 'logo', 'text', 'overlay', 'pdf', 'brand', 'mark'], cat: 'PDF', icon: '💧' },
    { name: 'Add Password to PDF', url: '/tools/add-password-pdf.html', tags: ['password', 'protect', 'lock', 'encrypt', 'secure', 'pdf', 'safety'], cat: 'PDF', icon: '🔒' },
    { name: 'Remove Password from PDF', url: '/tools/remove-password-pdf.html', tags: ['password', 'unlock', 'remove', 'decrypt', 'open', 'pdf', 'unprotect'], cat: 'PDF', icon: '🔓' },
    { name: 'Sign PDF', url: '/tools/sign-pdf.html', tags: ['sign', 'signature', 'draw', 'write', 'pdf', 'autograph', 'initial', 'esign'], cat: 'PDF', icon: '🖊️' },
    { name: 'OCR PDF', url: '/tools/ocr-pdf.html', tags: ['ocr', 'text', 'recognition', 'scan', 'read', 'extract', 'pdf', 'searchable'], cat: 'PDF', icon: '🔍' },
    { name: 'Image to Text (OCR)', url: '/tools/scan-image.html', tags: ['image to text', 'ocr', 'extract text', 'scan image', 'read', 'photo to text', 'recognize', 'optical character recognition'], cat: 'PDF', icon: '📷' },
    { name: 'PDF to Word', url: '/tools/pdf-to-word.html', tags: ['pdf', 'word', 'docx', 'doc', 'document', 'convert', 'office', 'microsoft'], cat: 'Convert', icon: '📝' },
    { name: 'Word to PDF', url: '/tools/word-to-pdf.html', tags: ['word', 'pdf', 'docx', 'doc', 'document', 'convert', 'office', 'microsoft'], cat: 'Convert', icon: '📄' },
    { name: 'PowerPoint to PDF', url: '/tools/powerpoint-to-pdf.html', tags: ['powerpoint', 'pptx', 'ppt', 'pdf', 'slides', 'presentation', 'convert', 'office'], cat: 'Convert', icon: '📊' },
    { name: 'Excel to PDF', url: '/tools/excel-to-pdf.html', tags: ['excel', 'xlsx', 'xls', 'pdf', 'spreadsheet', 'convert', 'office', 'table'], cat: 'Convert', icon: '📈' },

    // Image Tools
    { name: 'Image Compressor', url: '/tools/image-compressor.html', tags: ['image', 'compress', 'shrink', 'reduce', 'size', 'photo', 'picture', 'jpg', 'png', 'smaller'], cat: 'Compress', icon: '🗜️' },
    { name: 'Image Resizer', url: '/tools/image-resizer.html', tags: ['image', 'resize', 'scale', 'dimension', 'width', 'height', 'crop', 'photo'], cat: 'Tools', icon: '📐' },
    { name: 'JPG to PNG', url: '/tools/jpg-to-png.html', tags: ['jpg', 'jpeg', 'png', 'convert', 'image', 'transparent', 'background'], cat: 'Convert', icon: '🖼️' },
    { name: 'PNG to JPG', url: '/tools/png-to-jpg.html', tags: ['png', 'jpg', 'jpeg', 'convert', 'image', 'smaller', 'photo'], cat: 'Convert', icon: '🖼️' },
    { name: 'WEBP to JPG', url: '/tools/webp-to-jpg.html', tags: ['webp', 'jpg', 'jpeg', 'convert', 'image', 'google', 'chrome'], cat: 'Convert', icon: '🖼️' },
    { name: 'WEBP to PNG', url: '/tools/webp-to-png.html', tags: ['webp', 'png', 'convert', 'image', 'transparent'], cat: 'Convert', icon: '🖼️' },
    { name: 'JPG to WEBP', url: '/tools/jpg-to-webp.html', tags: ['jpg', 'jpeg', 'webp', 'convert', 'image', 'web', 'website', 'faster'], cat: 'Convert', icon: '🌐' },
    { name: 'PNG to WEBP', url: '/tools/png-to-webp.html', tags: ['png', 'webp', 'convert', 'image', 'web', 'website', 'faster'], cat: 'Convert', icon: '🌐' },
    { name: 'HEIC to JPG', url: '/tools/heic-to-jpg.html', tags: ['heic', 'heif', 'jpg', 'jpeg', 'iphone', 'apple', 'ios', 'photo', 'convert', 'open'], cat: 'Convert', icon: '📱' },

    // Video & Audio Converters
    { name: 'MP4 Converter', url: '/tools/mp4-converter.html', tags: ['mp4', 'video', 'convert', 'avi', 'mov', 'mkv', 'webm'], cat: 'Convert', icon: '🎬' },
    { name: 'MP3 Converter', url: '/tools/mp3-converter.html', tags: ['mp3', 'audio', 'convert', 'wav', 'ogg', 'flac', 'music', 'sound'], cat: 'Convert', icon: '🎵' },
    { name: 'MP4 to MP3', url: '/tools/mp4-to-mp3.html', tags: ['mp4', 'mp3', 'video', 'audio', 'extract', 'music', 'sound', 'convert', 'soundtrack'], cat: 'Convert', icon: '🎬' },
    { name: 'MP3 to MP4', url: '/tools/mp3-to-mp4.html', tags: ['mp3', 'mp4', 'audio', 'video', 'youtube', 'upload', 'cover', 'image'], cat: 'Convert', icon: '🎵' },
    { name: 'AVI to MP4', url: '/tools/avi-to-mp4.html', tags: ['avi', 'mp4', 'video', 'convert', 'old', 'format'], cat: 'Convert', icon: '🎞️' },
    { name: 'MOV to MP4', url: '/tools/mov-to-mp4.html', tags: ['mov', 'mp4', 'video', 'apple', 'iphone', 'quicktime', 'convert', 'ios'], cat: 'Convert', icon: '🍎' },
    { name: 'WebM to MP4', url: '/tools/webm-to-mp4.html', tags: ['webm', 'mp4', 'video', 'convert', 'chrome', 'browser', 'web'], cat: 'Convert', icon: '🌐' },
    { name: 'WAV to MP3', url: '/tools/wav-to-mp3.html', tags: ['wav', 'mp3', 'audio', 'convert', 'uncompressed', 'music', 'sound', 'smaller'], cat: 'Convert', icon: '🎶' },
    { name: 'OGG to MP3', url: '/tools/ogg-to-mp3.html', tags: ['ogg', 'mp3', 'vorbis', 'audio', 'convert', 'game', 'music'], cat: 'Convert', icon: '🎶' },

    // Compressors
    { name: 'Video Compressor', url: '/tools/video-compressor.html', tags: ['video', 'compress', 'shrink', 'reduce', 'size', 'mp4', 'movie', 'clip', 'smaller'], cat: 'Compress', icon: '🎬' },
    { name: 'Compress MP4', url: '/tools/compress-mp4.html', tags: ['mp4', 'compress', 'video', 'reduce', 'size', 'whatsapp', 'email', 'smaller', 'shrink'], cat: 'Compress', icon: '📦' },
    { name: 'Audio Compressor', url: '/tools/audio-compressor.html', tags: ['audio', 'compress', 'shrink', 'reduce', 'size', 'mp3', 'music', 'sound', 'smaller'], cat: 'Compress', icon: '🎵' },
    { name: 'Compress MP3', url: '/tools/compress-mp3.html', tags: ['mp3', 'compress', 'audio', 'reduce', 'size', 'bitrate', 'smaller', 'shrink', 'music'], cat: 'Compress', icon: '🔊' },
    { name: 'GIF Compressor', url: '/tools/gif-compressor.html', tags: ['gif', 'compress', 'reduce', 'size', 'animation', 'smaller', 'discord', 'shrink'], cat: 'Compress', icon: '🎞️' },

    // GIF Tools
    { name: 'GIF Maker', url: '/tools/gif-maker.html', tags: ['gif', 'make', 'create', 'animation', 'images', 'frames', 'animated'], cat: 'Tools', icon: '🎨' },
    { name: 'GIF Converter', url: '/tools/gif-converter.html', tags: ['gif', 'convert', 'mp4', 'video', 'webm', 'apng', 'animation'], cat: 'Tools', icon: '🔄' },

    // General Tools
    { name: 'QR Code Generator', url: '/tools/qr-code-generator.html', tags: ['qr', 'code', 'generate', 'barcode', 'scan', 'link', 'url', 'share'], cat: 'General', icon: '📲' },
    { name: 'Word Counter', url: '/tools/word-counter.html', tags: ['word', 'count', 'character', 'letter', 'text', 'paragraph', 'sentence', 'essay', 'writing'], cat: 'General', icon: '🔢' },
    { name: 'Color Picker', url: '/tools/color-picker.html', tags: ['color', 'colour', 'pick', 'hex', 'rgb', 'hsl', 'palette', 'design', 'eyedropper'], cat: 'General', icon: '🎨' },
    { name: 'Base64 Encoder', url: '/tools/base64-encoder.html', tags: ['base64', 'encode', 'decode', 'encoder', 'decoder', 'data uri', 'jwt', 'basic auth', 'mime', 'developer', 'crypto'], cat: 'General', icon: '🔤' },
    { name: 'Units Converter', url: '/tools/units-converter.html', tags: ['unit', 'convert', 'length', 'weight', 'temperature', 'meter', 'feet', 'kg', 'pound', 'celsius', 'fahrenheit', 'volume', 'speed', 'metric', 'imperial'], cat: 'General', icon: '📏' },
    { name: 'Time Converter', url: '/tools/time-converter.html', tags: ['time', 'zone', 'timezone', 'convert', 'clock', 'gmt', 'utc', 'est', 'pst', 'world', 'city', 'country'], cat: 'General', icon: '🕐' },
    { name: 'Trim Audio', url: '/tools/trim-audio.html', tags: ['trim', 'cut', 'audio', 'clip', 'ringtone', 'snippet', 'mp3', 'wav', 'ogg', 'waveform', 'crop', 'split', 'section'], cat: 'General', icon: '✂️' }
  ];

  // Simple fuzzy match — checks if query words appear in name or tags
  function score(tool, query) {
    var q = query.toLowerCase().trim();
    if (!q) return 0;
    var name = tool.name.toLowerCase();
    var allTags = tool.tags.join(' ');
    var words = q.split(/\s+/);
    var s = 0;

    // Exact name match gets highest score
    if (name === q) return 1000;
    // Name starts with query
    if (name.indexOf(q) === 0) return 900;
    // Name contains query as substring
    if (name.indexOf(q) !== -1) return 800;

    for (var i = 0; i < words.length; i++) {
      var w = words[i];
      if (w.length < 2) continue;

      // Exact word in name
      if (name.indexOf(w) !== -1) s += 100;
      // Exact word in tags
      else if (allTags.indexOf(w) !== -1) s += 50;
      // Fuzzy: 2+ chars match start of a tag
      else {
        for (var j = 0; j < tool.tags.length; j++) {
          if (tool.tags[j].indexOf(w) === 0 || (w.length >= 3 && tool.tags[j].indexOf(w) !== -1)) {
            s += 30;
            break;
          }
        }
      }
      // Levenshtein-light: allow 1 typo for words 4+ chars
      if (s === 0 && w.length >= 4) {
        for (var k = 0; k < tool.tags.length; k++) {
          if (tool.tags[k].length >= 3 && levenshtein1(w, tool.tags[k])) {
            s += 15;
            break;
          }
        }
        if (s === 0) {
          // Check against name words
          var nameWords = name.split(/\s+/);
          for (var m = 0; m < nameWords.length; m++) {
            if (nameWords[m].length >= 3 && levenshtein1(w, nameWords[m])) {
              s += 20;
              break;
            }
          }
        }
      }
    }
    return s;
  }

  // Returns true if edit distance is exactly 1 (simple typo detector)
  function levenshtein1(a, b) {
    if (Math.abs(a.length - b.length) > 1) return false;
    var diffs = 0, i = 0, j = 0;
    while (i < a.length && j < b.length) {
      if (a[i] !== b[j]) {
        diffs++;
        if (diffs > 1) return false;
        if (a.length > b.length) i++;
        else if (b.length > a.length) j++;
        else { i++; j++; }
      } else { i++; j++; }
    }
    return diffs + (a.length - i) + (b.length - j) <= 1;
  }

  function search(query) {
    if (!query || query.trim().length < 2) return [];
    var results = [];
    for (var i = 0; i < tools.length; i++) {
      var s = score(tools[i], query);
      if (s > 0) results.push({ tool: tools[i], score: s });
    }
    results.sort(function(a, b) { return b.score - a.score; });
    return results.slice(0, 6);
  }

  // Build dropdown UI
  function createDropdown(inputEl) {
    var dropdown = document.createElement('div');
    dropdown.className = 'search-dropdown';
    dropdown.style.cssText = 'position:absolute;top:100%;left:0;right:0;background:#fff;border:1px solid #E2E8F4;border-top:none;border-radius:0 0 14px 14px;box-shadow:0 12px 36px rgba(10,22,40,0.18);z-index:9999;max-height:360px;overflow-y:auto;display:none;';
    return dropdown;
  }

  function renderResults(dropdown, results, query) {
    if (results.length === 0) {
      dropdown.innerHTML = '<div style="padding:16px 20px;color:#6B7A99;font-size:14px;">No tools found for "<strong>' + escHtml(query) + '</strong>". <a href="/tools/all-tools.html" style="color:#1E6FFF;font-weight:600;">Browse all tools →</a></div>';
      dropdown.style.display = 'block';
      return;
    }
    var html = '';
    for (var i = 0; i < results.length; i++) {
      var t = results[i].tool;
      html += '<a href="' + t.url + '" class="search-result-item" style="display:flex;align-items:center;gap:12px;padding:12px 20px;text-decoration:none;color:#1A2340;font-size:14px;font-weight:500;transition:background 0.15s;border-bottom:1px solid #f0f2f5;">';
      html += '<span style="font-size:20px;width:32px;text-align:center;">' + t.icon + '</span>';
      html += '<span style="flex:1;">' + highlightMatch(t.name, query) + '</span>';
      html += '<span style="font-size:11px;color:#6B7A99;background:#F4F7FF;padding:3px 8px;border-radius:4px;">' + t.cat + '</span>';
      html += '</a>';
    }
    dropdown.innerHTML = html;
    dropdown.style.display = 'block';

    // Hover effects
    dropdown.querySelectorAll('.search-result-item').forEach(function(item) {
      item.addEventListener('mouseenter', function() { this.style.background = '#F4F7FF'; });
      item.addEventListener('mouseleave', function() { this.style.background = ''; });
    });
  }

  function highlightMatch(name, query) {
    var words = query.toLowerCase().trim().split(/\s+/);
    var result = name;
    for (var i = 0; i < words.length; i++) {
      if (words[i].length < 2) continue;
      var regex = new RegExp('(' + escRegex(words[i]) + ')', 'gi');
      result = result.replace(regex, '<strong style="color:#1E6FFF;">$1</strong>');
    }
    return result;
  }

  function escHtml(s) { return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
  function escRegex(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }

  // ========== HERO SEARCH BAR ==========
  function initHeroSearch() {
    var input = document.getElementById('heroSearch');
    if (!input) return;

    var parent = input.closest('.hero-search');
    if (parent) parent.style.position = 'relative';

    var dropdown = createDropdown(input);
    if (parent) parent.appendChild(dropdown);
    else input.parentElement.appendChild(dropdown);

    // Handle ?q= URL parameter (WebSite SearchAction sitelinks search box)
    try {
      var urlParams = new URLSearchParams(window.location.search);
      var qParam = urlParams.get('q');
      if (qParam && qParam.trim()) {
        input.value = qParam;
        var qResults = search(qParam);
        if (qResults.length > 0 && qResults[0].score >= 800) {
          window.location.href = qResults[0].tool.url;
          return;
        }
        setTimeout(function() {
          renderResults(dropdown, qResults, qParam);
          input.focus();
        }, 50);
      }
    } catch (e) { /* URLSearchParams unsupported (very old browsers) */ }

    var debounce = null;
    input.addEventListener('input', function() {
      clearTimeout(debounce);
      var val = this.value;
      debounce = setTimeout(function() {
        var results = search(val);
        if (val.trim().length >= 2) {
          renderResults(dropdown, results, val);
        } else {
          dropdown.style.display = 'none';
        }
      }, 150);
    });

    input.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        var results = search(this.value);
        if (results.length > 0) {
          window.location.href = results[0].tool.url;
          e.preventDefault();
        }
      }
      if (e.key === 'Escape') {
        dropdown.style.display = 'none';
      }
    });

    // Hide dropdown on outside click
    document.addEventListener('click', function(e) {
      if (!e.target.closest('.hero-search')) dropdown.style.display = 'none';
    });

    // Override the search button
    var btn = parent ? parent.querySelector('button') : null;
    if (btn) {
      btn.onclick = null;
      btn.removeAttribute('onclick');
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        var results = search(input.value);
        if (results.length > 0) {
          window.location.href = results[0].tool.url;
        } else if (input.value.trim()) {
          window.location.href = '/tools/all-tools.html';
        }
      });
    }
  }

  // ========== NAV SEARCH BUTTON ==========
  function initNavSearch() {
    var searchBtn = document.querySelector('.search-btn');
    if (!searchBtn) return;

    // Create search overlay
    var overlay = document.createElement('div');
    overlay.className = 'nav-search-overlay';
    overlay.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(10,22,40,0.5);z-index:9998;display:none;backdrop-filter:blur(4px);-webkit-backdrop-filter:blur(4px);opacity:0;transition:opacity 0.2s;';

    var modal = document.createElement('div');
    modal.className = 'nav-search-modal';
    modal.style.cssText = 'position:fixed;top:80px;left:50%;transform:translateX(-50%);width:90%;max-width:560px;background:#fff;border-radius:16px;box-shadow:0 20px 60px rgba(10,22,40,0.25);z-index:9999;overflow:hidden;display:none;opacity:0;transform:translateX(-50%) translateY(-10px);transition:opacity 0.2s, transform 0.2s;';

    var inputWrap = document.createElement('div');
    inputWrap.style.cssText = 'display:flex;align-items:center;padding:4px;border-bottom:1px solid #E2E8F4;';

    var searchIcon = document.createElement('span');
    searchIcon.textContent = '🔍';
    searchIcon.style.cssText = 'padding:12px 4px 12px 16px;font-size:18px;';

    var navInput = document.createElement('input');
    navInput.type = 'text';
    navInput.placeholder = 'Search 50 tools...';
    navInput.style.cssText = 'flex:1;border:none;outline:none;padding:14px 12px;font-size:16px;font-family:inherit;color:#1A2340;background:transparent;';
    navInput.id = 'navSearchInput';

    var closeBtn = document.createElement('button');
    closeBtn.textContent = '✕';
    closeBtn.style.cssText = 'background:none;border:none;font-size:18px;padding:12px 16px;cursor:pointer;color:#6B7A99;';

    inputWrap.appendChild(searchIcon);
    inputWrap.appendChild(navInput);
    inputWrap.appendChild(closeBtn);
    modal.appendChild(inputWrap);

    var navDropdown = document.createElement('div');
    navDropdown.className = 'nav-search-results';
    navDropdown.style.cssText = 'max-height:320px;overflow-y:auto;';
    modal.appendChild(navDropdown);

    document.body.appendChild(overlay);
    document.body.appendChild(modal);

    function openSearch() {
      overlay.style.display = 'block';
      modal.style.display = 'block';
      setTimeout(function() {
        overlay.style.opacity = '1';
        modal.style.opacity = '1';
        modal.style.transform = 'translateX(-50%) translateY(0)';
      }, 10);
      navInput.value = '';
      navInput.focus();
      navDropdown.innerHTML = '<div style="padding:16px 20px;color:#6B7A99;font-size:13px;">Type to search across 50+ free tools...</div>';
    }

    function closeSearch() {
      overlay.style.opacity = '0';
      modal.style.opacity = '0';
      modal.style.transform = 'translateX(-50%) translateY(-10px)';
      setTimeout(function() {
        overlay.style.display = 'none';
        modal.style.display = 'none';
      }, 200);
    }

    searchBtn.addEventListener('click', openSearch);
    overlay.addEventListener('click', closeSearch);
    closeBtn.addEventListener('click', closeSearch);

    // Keyboard shortcut: Ctrl+K or /
    document.addEventListener('keydown', function(e) {
      if ((e.ctrlKey && e.key === 'k') || (e.key === '/' && document.activeElement.tagName !== 'INPUT' && document.activeElement.tagName !== 'TEXTAREA')) {
        e.preventDefault();
        openSearch();
      }
      if (e.key === 'Escape' && modal.style.display === 'block') {
        closeSearch();
      }
    });

    var debounce2 = null;
    navInput.addEventListener('input', function() {
      clearTimeout(debounce2);
      var val = this.value;
      debounce2 = setTimeout(function() {
        var results = search(val);
        if (val.trim().length >= 2) {
          renderResults(navDropdown, results, val);
        } else {
          navDropdown.innerHTML = '<div style="padding:16px 20px;color:#6B7A99;font-size:13px;">Type to search across 50+ free tools...</div>';
        }
      }, 150);
    });

    navInput.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        var results = search(this.value);
        if (results.length > 0) {
          window.location.href = results[0].tool.url;
        }
      }
    });
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      initHeroSearch();
      initNavSearch();
    });
  } else {
    initHeroSearch();
    initNavSearch();
  }

})();
