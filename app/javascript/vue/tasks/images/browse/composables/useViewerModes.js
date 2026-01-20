import { computed } from 'vue'

export function useViewerModes({ mode, modes }) {
  const active = computed(() => modes[mode.value])
  const cursor = computed(() => active.value?.cursor?.value ?? 'default')

  function call(name, e) {
    active.value?.[name]?.(e)
  }

  return {
    active,
    cursor,
    onMouseDown: (e) => call('onMouseDown', e),
    onMouseMove: (e) => call('onMouseMove', e),
    onMouseUp: (e) => call('onMouseUp', e),
    onWheel: (e) => call('onWheel', e)
  }
}
