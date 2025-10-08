// Code by chatgpt.
// Returns true if e is a click over a 'full-screen' modal.
export function hasModalInEventPath(e) {
  const path = getEventPath(e)
  for (const n of path) {
    if (n && n.nodeType === 1) {
      const el = /** @type {Element} */ (n)
      // Fast selector check
      if (el.matches?.(MODAL_ANCESTOR_SELECTORS)) return true
      // Fallback geometry check (fullscreen overlay)
      if (isFullscreenLike(el)) return true
    }
  }
  return false
}

// Heuristic: viewport-sized fixed/absolute (covers fullscreen modals)
function isFullscreenLike(el) {
  if (!el || el.nodeType !== 1 || !el.getBoundingClientRect) return false

  const rect = el.getBoundingClientRect()
  const pos = getComputedStyle(el).position
  const nearFullW = rect.width >= window.innerWidth - 2
  const nearFullH = rect.height >= window.innerHeight - 2
  return (pos === 'fixed' || pos === 'absolute') && nearFullW && nearFullH
}

// Generic "modal-ish" markers.
const MODAL_ANCESTOR_SELECTORS = [
  '[aria-modal="true"]',
  '[role="dialog"]',
  '[role="alertdialog"]',
  '.modal',
  '.modal-mask',
  '.modal-wrapper',
  '.modal-container',
  '.overlay',
  '.dialog'
].join(',')

// Use the composed path if available (crosses shadow roots, respects SVG),
// otherwise build a path by walking parentNode (NOT parentElement).
function getEventPath(e) {
  if (typeof e.composedPath === 'function') return e.composedPath()

  const path = []
  let n = e.target
  while (n) {
    path.push(n)
    n = n.parentNode || n.host // n.host for ShadowRoot
  }
  path.push(window)
  return path
}

