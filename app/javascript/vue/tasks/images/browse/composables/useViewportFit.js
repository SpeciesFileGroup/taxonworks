import { ref, onMounted, onBeforeUnmount, watch } from 'vue'

export function useViewportFit({
  svgRef,
  imageWidth,
  imageHeight,
  viewport,
  pan,
  baseZoom,
  userZoom
}) {
  function fit() {
    const vw = svgRef.value.clientWidth
    const vh = svgRef.value.clientHeight

    viewport.value = { width: vw, height: vh }

    baseZoom.value = Math.min(vw / imageWidth.value, vh / imageHeight.value, 1)

    userZoom.value = 1

    const scaledW = imageWidth.value * baseZoom.value
    const scaledH = imageHeight.value * baseZoom.value

    pan.value = {
      x: (vw - scaledW) / 2,
      y: (vh - scaledH) / 2
    }
  }

  let ro

  onMounted(() => {
    fit()
    ro = new ResizeObserver(fit)
    ro.observe(svgRef.value)
  })

  onBeforeUnmount(() => {
    ro?.disconnect()
  })

  watch(() => [imageWidth, imageHeight], fit)

  return { fit }
}
