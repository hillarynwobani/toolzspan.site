/* ============================================
   TOOLZSPAN — Main JavaScript
   Shared across all pages
   ============================================ */

(function () {
  var MOBILE_BREAKPOINT = 768;

  function isMobile() {
    return window.innerWidth <= MOBILE_BREAKPOINT;
  }

  function closeMenu() {
    var navMenu = document.getElementById('navMenu');
    if (!navMenu) return;
    navMenu.classList.remove('active');
    document.body.classList.remove('menu-open');
    document.querySelectorAll('.nav-tab.is-active').forEach(function (t) {
      t.classList.remove('is-active');
    });
    document.querySelectorAll('.mega-col.is-active').forEach(function (c) {
      c.classList.remove('is-active');
    });
  }

  function getTabLabel(tab) {
    if (!tab) return '';
    var text = '';
    Array.prototype.forEach.call(tab.childNodes, function (n) {
      if (n.nodeType === Node.TEXT_NODE) text += n.textContent;
    });
    return text.trim();
  }

  function injectDrillBacks() {
    // Inject "Back" buttons into each L2 panel (.mega-dropdown) and L3 panel (.mega-col)
    document.querySelectorAll('.nav-tab > .mega-dropdown').forEach(function (panel) {
      if (panel.querySelector(':scope > .drill-back')) return;
      var label = getTabLabel(panel.parentElement);
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'drill-back';
      btn.setAttribute('aria-label', 'Back to menu');
      btn.innerHTML = 'Back<span class="drill-back-title">' + (label || 'Menu') + '</span>';
      btn.addEventListener('click', function (e) {
        e.stopPropagation();
        // Close any L3 first; if none open, close this L2
        var openCol = panel.querySelector('.mega-col.is-active');
        if (openCol) {
          openCol.classList.remove('is-active');
        } else {
          panel.parentElement.classList.remove('is-active');
        }
      });
      panel.insertBefore(btn, panel.firstChild);
    });

    document.querySelectorAll('.mega-col').forEach(function (col) {
      if (col.querySelector(':scope > .drill-back')) return;
      var headingEl = col.querySelector(':scope > .mega-col-heading');
      var label = headingEl ? headingEl.textContent.trim() : 'Category';
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'drill-back';
      btn.setAttribute('aria-label', 'Back to categories');
      btn.innerHTML = 'Back<span class="drill-back-title">' + label + '</span>';
      btn.addEventListener('click', function (e) {
        e.stopPropagation();
        col.classList.remove('is-active');
      });
      col.insertBefore(btn, col.firstChild);
    });
  }

  function initMenu() {
    var menuToggle = document.getElementById('menuToggle');
    var navMenu = document.getElementById('navMenu');
    if (!menuToggle || !navMenu) return;

    injectDrillBacks();

    // Hamburger toggle
    menuToggle.addEventListener('click', function (e) {
      e.stopPropagation();
      var willOpen = !navMenu.classList.contains('active');
      if (willOpen) {
        navMenu.classList.add('active');
        if (isMobile()) document.body.classList.add('menu-open');
      } else {
        closeMenu();
      }
    });

    // L1 (tab) click → open L2
    document.querySelectorAll('.nav-tab').forEach(function (tab) {
      tab.addEventListener('click', function (e) {
        if (!isMobile()) return;
        // Ignore clicks bubbling from inside the tab's mega-dropdown content
        if (e.target.closest('.mega-dropdown')) return;
        // Ignore clicks on a real link
        if (e.target.tagName === 'A') return;
        e.preventDefault();
        e.stopPropagation();
        // Close any other open tab/col
        document.querySelectorAll('.nav-tab.is-active').forEach(function (t) {
          if (t !== tab) t.classList.remove('is-active');
        });
        document.querySelectorAll('.mega-col.is-active').forEach(function (c) {
          c.classList.remove('is-active');
        });
        tab.classList.add('is-active');
      });
    });

    // L2 (mega-col-heading) click → open L3
    document.querySelectorAll('.mega-col-heading').forEach(function (heading) {
      heading.addEventListener('click', function (e) {
        if (!isMobile()) return;
        e.preventDefault();
        e.stopPropagation();
        var col = heading.closest('.mega-col');
        if (!col) return;
        // Close any other open col
        document.querySelectorAll('.mega-col.is-active').forEach(function (c) {
          if (c !== col) c.classList.remove('is-active');
        });
        col.classList.add('is-active');
      });
    });

    // Close on Escape
    document.addEventListener('keydown', function (e) {
      if (e.key !== 'Escape') return;
      if (!navMenu.classList.contains('active')) return;
      // Drill back step-by-step on Escape
      var openCol = document.querySelector('.mega-col.is-active');
      if (openCol) { openCol.classList.remove('is-active'); return; }
      var openTab = document.querySelector('.nav-tab.is-active');
      if (openTab) { openTab.classList.remove('is-active'); return; }
      closeMenu();
    });

    // Resize past breakpoint → reset all drill-down state
    var lastIsMobile = isMobile();
    window.addEventListener('resize', function () {
      var nowMobile = isMobile();
      if (nowMobile !== lastIsMobile) {
        closeMenu();
        lastIsMobile = nowMobile;
      }
    });
  }

  function initFaq() {
    document.querySelectorAll('.faq-question').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var item = this.closest('.faq-item');
        if (!item) return;
        document.querySelectorAll('.faq-item.open').forEach(function (openItem) {
          if (openItem !== item) openItem.classList.remove('open');
        });
        item.classList.toggle('open');
      });
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initMenu();
    initFaq();
  });
})();
