export function useViewerGestures(gestures) {
  function call(name, e) {
    Object.values(gestures).forEach((g) => {
      g?.[name]?.(e)
    })
  }

  return {
    onMouseDown: (e) => call('onMouseDown', e),
    onMouseMove: (e) => call('onMouseMove', e),
    onMouseUp: (e) => call('onMouseUp', e),
    onWheel: (e) => call('onWheel', e)
  }
}
