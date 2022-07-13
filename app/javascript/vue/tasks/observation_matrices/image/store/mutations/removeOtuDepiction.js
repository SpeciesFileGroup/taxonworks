export default (state, { rowIndex, index }) => {
  const depictions = state.observationRows[rowIndex].objectDepictions

  if (index > -1) {
    depictions.splice(index, 1)
  }
}
