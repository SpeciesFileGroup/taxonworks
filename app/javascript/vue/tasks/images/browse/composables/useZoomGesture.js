function svgPoint(evt, svg) {
  const pt = svg.createSVGPoint()

  pt.x = evt.clientX
  pt.y = evt.clientY

  return pt.matrixTransform(svg.getScreenCTM().inverse())
}

export function useZoomGesture(ctx) {
  function onWheel(evt) {
    if (!evt.altKey) return
    const zoomFactor = evt.deltaY < 0 ? 1.1 : 0.9
    const pt = svgPoint(evt, ctx.svgRef.value)

    ctx.pan.value.x = pt.x - (pt.x - ctx.pan.value.x) * zoomFactor
    ctx.pan.value.y = pt.y - (pt.y - ctx.pan.value.y) * zoomFactor

    ctx.userZoom.value *= zoomFactor
  }

  return {
    onWheel
  }
}
