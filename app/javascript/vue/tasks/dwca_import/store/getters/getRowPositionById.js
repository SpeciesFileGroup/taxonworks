export default (state) => (id) => {
  const pageIndex = state.datasetRecords.findIndex(page => page.rows.findIndex(item => item.id === id))
  return { pageIndex: pageIndex, rowIndex: state.datasetRecords[pageIndex].rows.findIndex(item => item.id === id) }
}
