export default (renderedCells, values) => {
  if (!Array.isArray(values)) return renderedCells
  if (!Array.isArray(renderedCells)) return values

  const cellByPosition = new Map(
    renderedCells.map((cell) => [`${cell.row}-${cell.column}`, cell])
  )

  return values.map((value) => {
    const renderedCell = cellByPosition.get(`${value.row}-${value.column}`)

    return renderedCell ? Object.assign(renderedCell, value) : value
  })
}
