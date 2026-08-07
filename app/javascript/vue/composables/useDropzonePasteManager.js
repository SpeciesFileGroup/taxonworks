const NON_TEXT_INPUT_TYPES = new Set([
  'button', 'checkbox', 'color', 'file',
  'hidden', 'image', 'radio', 'range', 'reset', 'submit'
])

function isTextEditable(el) {
  if (!el) return false
  if (el.isContentEditable) return true
  if (el.tagName === 'TEXTAREA') return true
  if (el.tagName === 'SELECT') return true
  if (el.tagName === 'INPUT') return !NON_TEXT_INPUT_TYPES.has(el.type)
  return false
}

// At module scope, shared by all users of this composable.
const state = {
  zones: new Set(), // { handler, prioritize }
  initialized: false
}

function resolveActiveZone() {
  const zones = Array.from(state.zones)

  if (zones.length === 1) return zones[0]

  const prioritized = zones.filter(z => z.prioritize)

  if (prioritized.length === 1) return prioritized[0]

  // none or multiple prioritized → disable
  return null
}

function onPaste(e) {
  if (isTextEditable(document.activeElement)) return

  const active = resolveActiveZone()
  if (!active) return

  active.handler(e)
}

function init() {
  if (state.initialized) return
  document.addEventListener('paste', onPaste)
  state.initialized = true
}

function cleanupIfEmpty() {
  if (state.zones.size === 0 && state.initialized) {
    document.removeEventListener('paste', onPaste)
    state.initialized = false
  }
}

export function useDropzonePasteManager() {
  function registerPaster(zone) {
    init()
    state.zones.add(zone)
  }

  function unregisterPaster(zone) {
    state.zones.delete(zone)
    cleanupIfEmpty()
  }

  return {
    registerPaster,
    unregisterPaster
  }
}