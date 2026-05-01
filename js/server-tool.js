/* ============================================
   TOOLZSPAN — Server-side tool client helper
   Posts a file + fields to /.netlify/functions/<name>
   Implements Section 4C-2 timeout + processing message + spinner
   ============================================ */

(function (global) {
  'use strict';

  function el(tag, props, children) {
    var e = document.createElement(tag);
    if (props) Object.keys(props).forEach(function (k) {
      if (k === 'className') e.className = props[k];
      else if (k === 'style') e.style.cssText = props[k];
      else if (k === 'innerHTML') e.innerHTML = props[k];
      else e.setAttribute(k, props[k]);
    });
    if (children) (Array.isArray(children) ? children : [children]).forEach(function (c) {
      e.appendChild(typeof c === 'string' ? document.createTextNode(c) : c);
    });
    return e;
  }

  function ensureProcessingUi(container) {
    var existing = container.querySelector('.server-tool-processing');
    if (existing) return existing;
    var msg = el('div', {
      className: 'server-tool-processing',
      style: 'display:none; background:#EEF4FF; border:1px solid #1E6FFF; border-radius:10px; padding:14px 18px; margin-top:14px; color:#0A1628; font-size:14px; font-weight:500; line-height:1.5;'
    });
    msg.innerHTML = '<span class="server-tool-spinner" style="display:inline-block; width:18px; height:18px; border:3px solid #E2E8F4; border-top:3px solid #1E6FFF; border-radius:50%; animation:server-tool-spin 0.8s linear infinite; margin-right:10px; vertical-align:middle;"></span>Processing your file&hellip; This may take up to 30 seconds for large files. <strong>Please do not close this tab.</strong>';
    container.appendChild(msg);

    if (!document.getElementById('server-tool-spinner-style')) {
      var style = document.createElement('style');
      style.id = 'server-tool-spinner-style';
      style.textContent = '@keyframes server-tool-spin { to { transform: rotate(360deg); } } .server-tool-error { background:#FDECEA; border:1px solid #E53935; color:#B71C1C; border-radius:10px; padding:14px 18px; margin-top:14px; font-size:14px; }';
      document.head.appendChild(style);
    }
    return msg;
  }

  function showError(container, message) {
    var err = container.querySelector('.server-tool-error');
    if (!err) {
      err = el('div', { className: 'server-tool-error' });
      container.appendChild(err);
    }
    err.textContent = message;
    err.style.display = 'block';
  }

  function hideMessages(container) {
    var p = container.querySelector('.server-tool-processing');
    if (p) p.style.display = 'none';
    var e = container.querySelector('.server-tool-error');
    if (e) e.style.display = 'none';
  }

  function downloadBlob(blob, filename) {
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(function () { URL.revokeObjectURL(url); }, 1500);
  }

  function getFilenameFromHeader(headerValue) {
    if (!headerValue) return null;
    var m = /filename="([^"]+)"/.exec(headerValue);
    return m ? m[1] : null;
  }

  /**
   * run({ endpoint, file, fields, container, fallbackName })
   * - endpoint: '/.netlify/functions/<name>'
   * - file: File object
   * - fields: { key: value }  // optional form fields
   * - container: DOM element to attach processing/error UI under (optional, defaults to document.body)
   * - fallbackName: filename to use if Content-Disposition missing
   * Returns Promise<{ blob, filename }>
   */
  async function run(opts) {
    var container = opts.container || document.body;
    var processing = ensureProcessingUi(container);
    hideMessages(container);
    processing.style.display = 'block';

    var form = new FormData();
    form.append('file', opts.file, opts.file.name);
    if (opts.fields) Object.keys(opts.fields).forEach(function (k) {
      if (opts.fields[k] !== undefined && opts.fields[k] !== null) form.append(k, opts.fields[k]);
    });

    try {
      var res = await fetch(opts.endpoint, { method: 'POST', body: form });
      processing.style.display = 'none';
      if (!res.ok) {
        var detail = '';
        try {
          var data = await res.json();
          detail = data && data.error ? data.error : '';
        } catch (_) { /* not JSON */ }
        var msg = (res.status === 504 || res.status === 502)
          ? 'Processing took too long. Please try a smaller file or try again shortly.'
          : (detail || ('Server error (' + res.status + ')'));
        showError(container, msg);
        throw new Error(msg);
      }
      var blob = await res.blob();
      var name = getFilenameFromHeader(res.headers.get('content-disposition')) || opts.fallbackName || 'download';
      return { blob: blob, filename: name };
    } catch (err) {
      processing.style.display = 'none';
      if (err.name === 'TypeError' || /fetch/.test(err.message || '')) {
        showError(container, 'Could not reach the server. Check your connection and try again.');
      } else if (!container.querySelector('.server-tool-error[style*="block"]')) {
        showError(container, err.message || 'Processing failed.');
      }
      throw err;
    }
  }

  global.ToolzspanServer = { run: run, downloadBlob: downloadBlob, showError: showError, hideMessages: hideMessages };
})(window);
