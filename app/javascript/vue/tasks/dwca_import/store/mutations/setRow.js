import Vue from 'vue'

export default (state, { index, row }) => {
  Vue.set(state.datasetRecords, index, row)
}
