export default (state, { pageNumber, page }) => {
  state.datasetRecords[pageNumber] = page
}
