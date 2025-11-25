import { onMounted, onBeforeUnmount } from 'vue'

export function useClickOutside(elementRef, callback) {
  function handleEvent(event) {
    const el = elementRef.value

    if (!el) return

    if (!event.target || !el.contains(event.target)) {
      callback(event)
    }
  }

  onMounted(() => {
    document.addEventListener('pointerdown', handleEvent, {
      passive: true,
      capture: true
    })
    document.addEventListener('contextmenu', handleEvent, {
      passive: true,
      capture: true
    })
  })

  onBeforeUnmount(() => {
    document.removeEventListener('pointerdown', handleEvent, {
      capture: true
    })
    document.removeEventListener('contextmenu', handleEvent, {
      capture: true
    })
  })
}
