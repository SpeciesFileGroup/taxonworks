import { ref } from 'vue'

export function useMeasurements(svgRef, contentRef) {
  const measurements = ref([])
  const drawing = ref(false)

  const startPoint = ref(null)
  const currentPoint = ref(null)

  function svgPoint(evt) {
    const svg = svgRef.value
    const content = contentRef.value

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

  function startMeasurement(e) {
    const p = svgPoint(e)
    if (!p) return

    drawing.value = true
    startPoint.value = p
    currentPoint.value = { ...p }
  }

  function moveMeasurement(e) {
    if (!drawing.value) return

    const p = svgPoint(e)
    if (!p) return

    currentPoint.value = p
  }

  function endMeasurement() {
    if (!drawing.value || !startPoint.value || !currentPoint.value) return

    measurements.value.push({
      x1: startPoint.value.x,
      y1: startPoint.value.y,
      x2: currentPoint.value.x,
      y2: currentPoint.value.y
    })

    drawing.value = false
  }

  return {
    measurements,
    drawing,
    startPoint,
    currentPoint,
    startMeasurement,
    moveMeasurement,
    endMeasurement
  }
}
