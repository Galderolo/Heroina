// Scroll-to-top compartido (ES Module)

export function setupScrollToTop({ buttonId = 'scrollToTop', threshold = 300 } = {}) {
  const scrollToTopBtn = document.getElementById(buttonId);
  if (!scrollToTopBtn) return;

  window.addEventListener('scroll', () => {
    if (window.pageYOffset > threshold) scrollToTopBtn.classList.add('visible');
    else scrollToTopBtn.classList.remove('visible');
  });

  scrollToTopBtn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });
}

