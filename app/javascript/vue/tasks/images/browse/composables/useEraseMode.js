// composables/modes/useEraseMode.js
import { svgPoint } from '../utils/svgPoint'
import { pointToSegmentDistance } from '../utils/pointToSegmentDistance'
import { computed } from 'vue'

export function useEraseMode(ctx) {
  const HIT_RADIUS = 6
  const SVG_ICON = `
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 22 18">
      <path fill="white" stroke="black" stroke-weight="1" d="M12.728 12.728L8.485 8.485l-5.657 5.657l2.122 2.121a3 3 0 0 0 4.242 0zM11.284 17H14a1 1 0 0 1 0 2H3a1 1 0 0 1-.133-1.991l-1.453-1.453a2 2 0 0 1 0-2.828L12.728 1.414a2 2 0 0 1 2.828 0L19.8 5.657a2 2 0 0 1 0 2.828z"/>
    </svg>
  `

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
    cursor: computed(
      () =>
        `url("data:image/svg+xml,${encodeURIComponent(SVG_ICON.trim())}") 5 20, auto`
    ),
    onMouseDown,
    onMouseMove
  }
}
