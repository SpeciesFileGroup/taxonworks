import Vue from 'vue'

export default (state, { pageNumber, page }) => {
  Vue.set(state.datasetRecords, pageNumber, page)
}
