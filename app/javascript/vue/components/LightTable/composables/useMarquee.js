import { reactive, computed } from 'vue'

export function useMarquee() {
  const state = reactive({ active: false, x0: 0, y0: 0, x1: 0, y1: 0 })

  const rect = computed(() => ({
    x: Math.min(state.x0, state.x1),
    y: Math.min(state.y0, state.y1),
    w: Math.abs(state.x1 - state.x0),
    h: Math.abs(state.y1 - state.y0)
  }))

  function begin(x, y) {
    state.active = true
    state.x0 = x
    state.y0 = y
    state.x1 = x
    state.y1 = y
  }

  function move(x, y) {
    if (!state.active) return
    state.x1 = x
    state.y1 = y
  }

  function finish() {
    if (!state.active) return null
    state.active = false
    return { ...rect.value }
  }

  function cancel() {
    state.active = false
  }

  return { state, rect, begin, move, finish, cancel }
}
