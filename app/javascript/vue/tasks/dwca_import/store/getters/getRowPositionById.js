export default (state) => (id) => {
  for (let i = 0; i < state.datasetRecords.length; i++) {
    if (state.datasetRecords[i].rows) {
      const rowIndex = state.datasetRecords[i].rows.findIndex(item => item.id === id)
      if (rowIndex > -1) {
        return { pageIndex: i, rowIndex: rowIndex }
      }
    }
  }
  return undefined
}
