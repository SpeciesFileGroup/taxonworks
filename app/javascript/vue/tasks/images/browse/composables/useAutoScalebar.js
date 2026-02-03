import { computed } from 'vue'

const NICE_SCALES_CM = [0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10]

export function useAutoScalebar({ pixelsToCentimeters, zoom, targetPx = 120 }) {
  return computed(() => {
    if (!pixelsToCentimeters.value || !zoom.value) {
      return {
        cm: 1,
        px: pixelsToCentimeters.value || 1
      }
    }

    let best = {
      cm: 1,
      px: pixelsToCentimeters.value * zoom.value
    }

    let bestDelta = Infinity

    for (const cm of NICE_SCALES_CM) {
      const px = cm * pixelsToCentimeters.value * zoom.value
      const delta = Math.abs(px - targetPx)

      if (delta < bestDelta) {
        bestDelta = delta
        best = { cm, px }
      }
    }

    return best
  })
}
