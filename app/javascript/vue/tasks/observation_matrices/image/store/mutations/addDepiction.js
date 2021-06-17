export default (state, { rowIndex, columnIndex, depiction }) => {
  const depictions = state.observationRows[rowIndex].depictions[columnIndex]
  const index = depictions.findIndex(d => d.id === depiction.id)

  if (index > -1) {
    depictions[index] = depiction
  } else {
    depictions.push(depiction)
  }
}
