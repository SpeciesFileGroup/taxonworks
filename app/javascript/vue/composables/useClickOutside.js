import { onMounted, onBeforeUnmount } from 'vue'

export function useClickOutside(elementRef, callback) {
  function handleEvent(event) {
    const elements = (Array.isArray(elementRef) ? elementRef : [elementRef])
      .map((ref) => ref.value)
      .filter(Boolean)

    if (!elements.length) return

    if (!event.target || !elements.some((el) => el.contains(event.target))) {
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
