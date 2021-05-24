export default (state, { rowIndex, columnIndex, index }) => {
  const depictions = state.observationRows[rowIndex].depictions[columnIndex]

  console.log('se')
  if (index > -1) {
    console.log('borra')
    state.observationRows[rowIndex].depictions[columnIndex].splice(index, 1)
  }
}
