export function svgPoint({ evt, ctx }) {
  const svg = ctx.svgRef.value
  const content = ctx.contentRef.value

  if (!svg || !content) return null

  const pt = svg.createSVGPoint()
  pt.x = evt.clientX
  pt.y = evt.clientY

  const svgP = pt.matrixTransform(svg.getScreenCTM().inverse())

  const ctm = content.getCTM()
  if (!ctm) return null

  const imgP = svgP.matrixTransform(ctm.inverse())

  if (Number.isNaN(imgP.x) || Number.isNaN(imgP.y)) {
    return null
  }

  return { x: imgP.x, y: imgP.y }
}
