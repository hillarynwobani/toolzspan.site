/* ============================================
   TOOLZSPAN — Main JavaScript
   Shared across all pages
   ============================================ */

(function () {
  var MOBILE_BREAKPOINT = 768;
  var savedScrollY = 0;

  function isMobile() {
    return window.innerWidth <= MOBILE_BREAKPOINT;
  }

  // iOS-safe scroll lock: `body { overflow: hidden }` alone does NOT lock scroll on
  // iOS Safari, and position:fixed children can render against the layout viewport
  // instead of the visual viewport, making the close (X) button invisible. The fix
  // is to pin the body itself at the current scroll offset so the drawer and its X
  // button always sit against the visible viewport.
  function lockBodyScroll() {
    savedScrollY = window.scrollY || window.pageYOffset || 0;
    var body = document.body;
    body.style.position = 'fixed';
    body.style.top = '-' + savedScrollY + 'px';
    body.style.left = '0';
    body.style.right = '0';
    body.style.width = '100%';
  }

  function unlockBodyScroll() {
    var body = document.body;
    body.style.position = '';
    body.style.top = '';
    body.style.left = '';
    body.style.right = '';
    body.style.width = '';
    window.scrollTo(0, savedScrollY);
  }

  function closeMenu() {
    var navMenu = document.getElementById('navMenu');
    if (!navMenu) return;
    var wasOpen = document.body.classList.contains('menu-open');
    navMenu.classList.remove('active');
    document.body.classList.remove('menu-open');
    var toggle = document.getElementById('menuToggle');
    if (toggle) toggle.classList.remove('is-open');
    document.querySelectorAll('.nav-tab.is-active').forEach(function (t) {
      t.classList.remove('is-active');
    });
    document.querySelectorAll('.mega-col.is-active').forEach(function (c) {
      c.classList.remove('is-active');
    });
    syncAriaExpanded();
    if (wasOpen) unlockBodyScroll();
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
      btn.innerHTML = 'Back <span class="drill-back-title">' + (label || 'Menu') + '</span>';
      btn.addEventListener('click', function (e) {
        e.stopPropagation();
        // Close any L3 first; if none open, close this L2
        var openCol = panel.querySelector('.mega-col.is-active');
        if (openCol) {
          openCol.classList.remove('is-active');
        } else {
          panel.parentElement.classList.remove('is-active');
        }
        syncAriaExpanded();
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
      btn.innerHTML = 'Back <span class="drill-back-title">' + label + '</span>';
      btn.addEventListener('click', function (e) {
        e.stopPropagation();
        col.classList.remove('is-active');
        syncAriaExpanded();
      });
      col.insertBefore(btn, col.firstChild);
    });
  }

  // a11y: .nav-tab and .mega-col-heading are <div>s with click handlers.
  // Without role/tabindex/aria-expanded, screen readers (TalkBack on Android,
  // VoiceOver on iOS) cannot tell they are interactive. We add them at runtime
  // so no HTML markup changes are needed across 80+ pages.
  function annotateMenuA11y() {
    document.querySelectorAll('.nav-tab').forEach(function (tab) {
      tab.setAttribute('role', 'button');
      tab.setAttribute('tabindex', '0');
      tab.setAttribute('aria-haspopup', 'true');
      tab.setAttribute('aria-expanded', tab.classList.contains('is-active') ? 'true' : 'false');
      // Activate via Enter / Space when focused (keyboard parity with click)
      tab.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter' && e.key !== ' ' && e.key !== 'Spacebar') return;
        if (e.target.closest('.mega-dropdown')) return;
        if (e.target.tagName === 'A') return;
        e.preventDefault();
        tab.click();
      });
    });

    document.querySelectorAll('.mega-col-heading').forEach(function (heading) {
      var col = heading.closest('.mega-col');
      heading.setAttribute('role', 'button');
      heading.setAttribute('tabindex', '0');
      heading.setAttribute('aria-haspopup', 'true');
      heading.setAttribute('aria-expanded', col && col.classList.contains('is-active') ? 'true' : 'false');
      heading.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter' && e.key !== ' ' && e.key !== 'Spacebar') return;
        e.preventDefault();
        heading.click();
      });
    });
  }

  // Keep aria-expanded in sync with .is-active state changes.
  function syncAriaExpanded() {
    document.querySelectorAll('.nav-tab').forEach(function (tab) {
      tab.setAttribute('aria-expanded', tab.classList.contains('is-active') ? 'true' : 'false');
    });
    document.querySelectorAll('.mega-col').forEach(function (col) {
      var heading = col.querySelector(':scope > .mega-col-heading');
      if (!heading) return;
      heading.setAttribute('aria-expanded', col.classList.contains('is-active') ? 'true' : 'false');
    });
  }

  function initMenu() {
    var menuToggle = document.getElementById('menuToggle');
    var navMenu = document.getElementById('navMenu');
    if (!menuToggle || !navMenu) return;

    injectDrillBacks();
    annotateMenuA11y();

    // Hamburger toggle (also acts as X close button when open)
    menuToggle.setAttribute('aria-expanded', 'false');
    menuToggle.addEventListener('click', function (e) {
      e.stopPropagation();
      var willOpen = !navMenu.classList.contains('active');
      if (willOpen) {
        // Lock body scroll BEFORE adding .menu-open so the scrollY captured by
        // lockBodyScroll() is the pre-open position. Without this order, the
        // CSS rule `body.menu-open { overflow: hidden }` could fire first and
        // briefly reset scroll on some mobile browsers.
        if (isMobile()) lockBodyScroll();
        navMenu.classList.add('active');
        menuToggle.classList.add('is-open');
        menuToggle.setAttribute('aria-expanded', 'true');
        menuToggle.setAttribute('aria-label', 'Close navigation');
        if (isMobile()) document.body.classList.add('menu-open');
      } else {
        closeMenu();
        menuToggle.setAttribute('aria-expanded', 'false');
        menuToggle.setAttribute('aria-label', 'Open navigation');
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
        syncAriaExpanded();
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
        syncAriaExpanded();
      });
    });

    // Close on Escape
    document.addEventListener('keydown', function (e) {
      if (e.key !== 'Escape') return;
      if (!navMenu.classList.contains('active')) return;
      // Drill back step-by-step on Escape
      var openCol = document.querySelector('.mega-col.is-active');
      if (openCol) { openCol.classList.remove('is-active'); syncAriaExpanded(); return; }
      var openTab = document.querySelector('.nav-tab.is-active');
      if (openTab) { openTab.classList.remove('is-active'); syncAriaExpanded(); return; }
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

  function initLazySearch() {
    var searchBtn = document.querySelector('.search-btn');
    if (!searchBtn) return;
    searchBtn.addEventListener('click', function (e) {
      if (window.searchLoaded) return;
      e.stopImmediatePropagation();
      window.searchLoaded = true;
      var s = document.createElement('script');
      var isDeep = location.pathname.indexOf('/tools/') > -1 || location.pathname.indexOf('/blog/') > -1;
      s.src = isDeep ? '../js/search.js' : 'js/search.js';
      s.onload = function () {
        var event = new MouseEvent('click', { bubbles: true, cancelable: true });
        searchBtn.dispatchEvent(event);
      };
      document.body.appendChild(s);
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initMenu();
    initFaq();
    initLazySearch();
  });
})();
