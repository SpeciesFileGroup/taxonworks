import Vue from 'vue'

export default (state, { pageIndex, rowIndex, row }) => {
  Vue.set(state.datasetRecords[pageIndex].rows, rowIndex, row)
}
