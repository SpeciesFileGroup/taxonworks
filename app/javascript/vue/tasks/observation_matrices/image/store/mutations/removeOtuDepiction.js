export default (state, { rowIndex, index }) => {
  console.log(rowIndex)
  console.log(index)
  const depictions = state.observationRows[rowIndex].objectDepictions

  if (index > -1) {
    depictions.splice(index, 1)
  }
}
