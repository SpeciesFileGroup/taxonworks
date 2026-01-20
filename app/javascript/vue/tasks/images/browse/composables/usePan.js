import { computed, ref } from 'vue'

export function usePanMode(ctx) {
  const panning = ref(false)
  const startMouse = ref(null)
  const startPan = ref(null)

  function onMouseDown(e) {
    panning.value = true
    startMouse.value = { x: e.clientX, y: e.clientY }
    startPan.value = { ...ctx.pan.value }
  }

  function onMouseMove(e) {
    if (!panning.value) return

    const dx = e.clientX - startMouse.value.x
    const dy = e.clientY - startMouse.value.y

    ctx.pan.value.x = startPan.value.x + dx
    ctx.pan.value.y = startPan.value.y + dy
  }

  function onMouseUp() {
    panning.value = false
  }

  return {
    cursor: computed(() => 'grab'),
    onMouseDown,
    onMouseMove,
    onMouseUp
  }
}
