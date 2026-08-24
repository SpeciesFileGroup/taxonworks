import incrementIdentifier from '@/tasks/digitize/helpers/incrementIdentifier.js'

const sectionKey = (row, column) => `${row}-${column}`

const maxIndex = (metadata, key) =>
  metadata.reduce((max, cell) => Math.max(max, Number(cell[key])), 0)

const indexRange = (lastIndex, isReversed) => {
  const indexes = [...Array(lastIndex + 1).keys()]

  return isReversed ? indexes.reverse() : indexes
}

export const orderedSections = (
  metadata,
  {
    stepIdentifierOn = 'column',
    horizontalStepDirection = 'left_to_right',
    verticalStepDirection = 'top_to_bottom'
  } = {}
) => {
  if (!metadata.length) return []

  const rows = indexRange(
    maxIndex(metadata, 'row'),
    verticalStepDirection === 'bottom_to_top'
  )
  const columns = indexRange(
    maxIndex(metadata, 'column'),
    horizontalStepDirection === 'right_to_left'
  )
  const isRowFirst = stepIdentifierOn === 'row'
  const [outerIndexes, innerIndexes] = isRowFirst
    ? [rows, columns]
    : [columns, rows]

  return outerIndexes.flatMap((outerIndex) =>
    innerIndexes.map((innerIndex) =>
      isRowFirst ? [outerIndex, innerIndex] : [innerIndex, outerIndex]
    )
  )
}

export default (metadata, { firstIdentifier, ...stepOptions } = {}) => {
  const identifiers = new Map()

  if (!firstIdentifier) return identifiers

  const availableSections = new Set(
    metadata
      .filter((cell) => cell.metadata == null)
      .map((cell) => sectionKey(cell.row, cell.column))
  )

  let increment = 0

  orderedSections(metadata, stepOptions).forEach(([row, column]) => {
    const key = sectionKey(row, column)

    if (!availableSections.has(key)) return

    identifiers.set(key, incrementIdentifier(firstIdentifier, increment))
    increment++
  })

  return identifiers
}
