// composables/modes/useEraseMode.js
import { svgPoint } from '../utils/svgPoint'
import { pointToSegmentDistance } from '../utils/pointToSegmentDistance'
import { computed } from 'vue'

export function useEraseMode(ctx) {
  const HIT_RADIUS = 6

  function eraseAt(evt) {
    const p = svgPoint({ evt, ctx })

    ctx.measurements.value = ctx.measurements.value.filter((m) => {
      const d = pointToSegmentDistance(p.x, p.y, m.x1, m.y1, m.x2, m.y2)

      return d > HIT_RADIUS
    })
  }

  function onMouseDown(evt) {
    eraseAt(evt)
  }

  function onMouseMove(evt) {
    if (evt.buttons !== 1) return
    eraseAt(evt)
  }

  return {
    cursor: computed(() => 'not-allowed'),
    onMouseDown,
    onMouseMove
  }
}
