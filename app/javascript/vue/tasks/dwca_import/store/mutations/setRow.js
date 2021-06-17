export default (state, { pageIndex, rowIndex, row }) => {
  state.datasetRecords[pageIndex].rows[rowIndex] = row
}
