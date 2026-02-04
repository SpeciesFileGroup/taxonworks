import { computed } from 'vue'

export function usePanGesture(ctx) {
  const SPEED = 0.2

  function onWheel(e) {
    e.preventDefault()

    const delta = e.deltaY * (SPEED * ctx.zoom.value)

    if (e.ctrlKey) {
      ctx.pan.value.x -= delta / ctx.zoom.value
    } else {
      ctx.pan.value.y -= delta / ctx.zoom.value
    }
  }

  return {
    onWheel,
    cursor: computed(() => 'grab')
  }
}
