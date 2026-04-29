/* ============================================
   TOOLZSPAN — Main JavaScript
   Shared across all pages
   ============================================ */

// Mobile menu toggle
document.addEventListener('DOMContentLoaded', function() {
  var menuToggle = document.getElementById('menuToggle');
  var navMenu = document.getElementById('navMenu');

  if (menuToggle && navMenu) {
    menuToggle.addEventListener('click', function() {
      navMenu.classList.toggle('active');
    });
  }

  // Mobile accordion for mega-menu tabs
  function initMobileAccordion() {
    if (window.innerWidth <= 768) {
      document.querySelectorAll('.nav-tab').forEach(function(tab) {
        tab.addEventListener('click', function(e) {
          if (e.target.closest('.mega-dropdown') || e.target.tagName === 'A') return;
          e.preventDefault();
          // Close other tabs
          document.querySelectorAll('.nav-tab').forEach(function(t) {
            if (t !== tab) t.classList.remove('accordion-open');
          });
          this.classList.toggle('accordion-open');
        });
      });
    }
  }
  initMobileAccordion();

  // FAQ accordion
  document.querySelectorAll('.faq-question').forEach(function(btn) {
    btn.addEventListener('click', function() {
      this.closest('.faq-item').classList.toggle('open');
    });
  });
});
