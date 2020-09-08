import Vue from 'vue'

export default (state, { pageIndex, rowIndex, row }) => {
  Vue.set(state.datasetRecords[pageIndex], rowIndex, row)
}
