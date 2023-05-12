import { addToArray } from 'helpers/arrays'

export default (state, { rowIndex, columnIndex, depiction }) => {
  const depictions = state.observationRows[rowIndex].depictions[columnIndex]

  addToArray(depictions, depiction)
}
