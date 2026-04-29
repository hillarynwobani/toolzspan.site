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
  }

  // Mobile accordion for mega-menu tabs — always bind, CSS controls visibility
  document.querySelectorAll('.nav-tab').forEach(function(tab) {
    tab.addEventListener('click', function(e) {
      // Only act on mobile
      if (window.innerWidth > 768) return;
      // Don't intercept clicks on links inside the dropdown
      if (e.target.closest('.mega-dropdown') || e.target.tagName === 'A') return;
      e.preventDefault();
      e.stopPropagation();
      // Close other tabs
      document.querySelectorAll('.nav-tab').forEach(function(t) {
        if (t !== tab) t.classList.remove('accordion-open');
      });
      this.classList.toggle('accordion-open');
    });
  });

  // Close mobile menu when clicking a link inside the dropdown
  document.querySelectorAll('.mega-dropdown a').forEach(function(link) {
    link.addEventListener('click', function() {
      if (window.innerWidth <= 768 && navMenu) {
        navMenu.classList.remove('active');
        document.querySelectorAll('.nav-tab').forEach(function(t) {
          t.classList.remove('accordion-open');
        });
      }
    });
  });

  // Close mobile menu on resize to desktop
  window.addEventListener('resize', function() {
    if (window.innerWidth > 768 && navMenu) {
      navMenu.classList.remove('active');
      document.querySelectorAll('.nav-tab').forEach(function(t) {
        t.classList.remove('accordion-open');
      });
    }
  });

  // FAQ accordion
  document.querySelectorAll('.faq-question').forEach(function(btn) {
    btn.addEventListener('click', function() {
      this.closest('.faq-item').classList.toggle('open');
    });
  });
});
