import { shorten } from '@/helpers'
import { comparePosition, convertPositionTo3DGraph } from './index.js'
import { ERROR_COLOR, HOVER_COLOR, DEFAULT_COLOR } from '../constants'

function makeStyle({ item, isHover }) {
  return {
    color:
      (isHover && HOVER_COLOR) ||
      (item.errorOnSave && ERROR_COLOR) ||
      DEFAULT_COLOR
  }
}

export function makeVisualizerContainerItem(
  item,
  { truncateMaxLength, hoverRow, container }
) {
  const isHover = hoverRow && comparePosition(item.position, hoverRow.position)
  const label = truncateMaxLength
    ? shorten(item.label, truncateMaxLength)
    : item.label
  const style = makeStyle({ item, isHover })

  return {
    position: convertPositionTo3DGraph(item.position, container.size),
    metadata: item,
    label,
    style
  }
}
