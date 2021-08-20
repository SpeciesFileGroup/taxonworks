export default (state, { rowIndex, columnIndex, index }) => {
  const depictions = state.observationRows[rowIndex].depictions[columnIndex]

  if (index > -1) {
    state.observationRows[rowIndex].depictions[columnIndex].splice(index, 1)
  }
}
