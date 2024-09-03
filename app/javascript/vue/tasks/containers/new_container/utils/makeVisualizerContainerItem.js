import { shorten } from '@/helpers'
import { comparePosition, convertPositionTo3DGraph } from './index.js'
import { HOVER_COLOR } from '../constants'

export function makeVisualizerContainerItem(
  item,
  { truncateMaxLength, hoverRow, container }
) {
  const label = truncateMaxLength
    ? shorten(item.label, truncateMaxLength)
    : item.label
  const style =
    hoverRow && comparePosition(item.position, hoverRow.position)
      ? { color: HOVER_COLOR }
      : {}

  return {
    position: convertPositionTo3DGraph(item.position, container.size),
    metadata: item,
    label,
    style
  }
}
