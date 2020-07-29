export default (state) => (id) => state.datasetRecords.findIndex(item => item.id === id)
