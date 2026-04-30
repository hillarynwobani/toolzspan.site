/* ============================================
   TOOLZSPAN — Main JavaScript
   Shared across all pages
   ============================================ */

document.addEventListener('DOMContentLoaded', function() {
  var menuToggle = document.getElementById('menuToggle');
  var navMenu = document.getElementById('navMenu');

  // Mobile menu toggle
  if (menuToggle && navMenu) {
    menuToggle.addEventListener('click', function() {
      navMenu.classList.toggle('active');
    });
    // Close menu when clicking outside
    document.addEventListener('click', function(e) {
      if (!e.target.closest('.nav-menu') && !e.target.closest('#menuToggle')) {
        navMenu.classList.remove('active');
      }
    });
  }

  // Mobile accordion for mega-menu tabs
  var accordionBound = false;
  function handleTabClick(e) {
    if (e.target.closest('.mega-dropdown') || e.target.tagName === 'A') return;
    e.preventDefault();
    var tab = this;
    document.querySelectorAll('.nav-tab').forEach(function(t) {
      if (t !== tab) t.classList.remove('accordion-open');
    });
    tab.classList.toggle('accordion-open');
  }

  function initMobileAccordion() {
    var tabs = document.querySelectorAll('.nav-tab');
    if (window.innerWidth <= 768) {
      if (!accordionBound) {
        tabs.forEach(function(tab) {
          tab.addEventListener('click', handleTabClick);
        });
        accordionBound = true;
      }
    } else {
      // Desktop: remove accordion behavior and open states
      tabs.forEach(function(tab) {
        tab.classList.remove('accordion-open');
        tab.removeEventListener('click', handleTabClick);
      });
      accordionBound = false;
    }
  }

  initMobileAccordion();
  window.addEventListener('resize', initMobileAccordion);

  // FAQ accordion
  document.querySelectorAll('.faq-question').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var item = this.closest('.faq-item');
      // Close others
      document.querySelectorAll('.faq-item.open').forEach(function(openItem) {
        if (openItem !== item) openItem.classList.remove('open');
      });
      item.classList.toggle('open');
    });
  });
});
