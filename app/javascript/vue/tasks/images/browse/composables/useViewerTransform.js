export function useViewerTransform({ svgRef, pan, zoom }) {
  function screenToImage(evt) {
    const svg = svgRef.value
    const pt = svg.createSVGPoint()
    pt.x = evt.clientX
    pt.y = evt.clientY
    return pt.matrixTransform(svg.getScreenCTM().inverse())
  }

  function screenDeltaToImage(dx, dy) {
    return {
      x: dx / zoom.value,
      y: dy / zoom.value
    }
  }

  return {
    screenToImage,
    screenDeltaToImage
  }
}
