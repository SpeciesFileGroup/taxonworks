import { ref, onMounted, onBeforeUnmount } from 'vue'

function svgPoint(evt, svg) {
  const pt = svg.createSVGPoint()

  pt.x = evt.clientX
  pt.y = evt.clientY

  return pt.matrixTransform(svg.getScreenCTM().inverse())
}

export function useZoom(ctx) {
  const cursor = ref('zoom-in')

  function onMouseDown(evt) {
    const factor = evt.altKey ? 0.9 : 1.1
    const pt = svgPoint(evt, ctx.svgRef.value)

    ctx.pan.value.x = pt.x - (pt.x - ctx.pan.value.x) * factor
    ctx.pan.value.y = pt.y - (pt.y - ctx.pan.value.y) * factor

    ctx.userZoom.value *= factor
  }

  function onKeydown(e) {
    cursor.value = e.altKey ? 'zoom-out' : 'zoom-in'
  }

  onMounted(() => {
    window.addEventListener('keydown', onKeydown)
    window.addEventListener('keyup', onKeydown)
  })
  onBeforeUnmount(() => {
    window.addEventListener('keydown', onKeydown)
    window.addEventListener('keyup', onKeydown)
  })

  return {
    cursor,
    onMouseDown
  }
}
