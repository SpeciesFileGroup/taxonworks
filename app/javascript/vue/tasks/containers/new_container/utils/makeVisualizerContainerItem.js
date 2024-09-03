import { shorten } from '@/helpers'
import { comparePosition } from './comparePosition'
import { HOVER_COLOR } from '../constants'

export function makeVisualizerContainerItem(
  item,
  { truncateMaxLength, hoverRow }
) {
  const label = truncateMaxLength
    ? shorten(item.label, truncateMaxLength)
    : item.label
  const style =
    hoverRow && comparePosition(item.position, hoverRow.position)
      ? { color: HOVER_COLOR }
      : {}

  return {
    position: item.position,
    metadata: item,
    label,
    style
  }
}
