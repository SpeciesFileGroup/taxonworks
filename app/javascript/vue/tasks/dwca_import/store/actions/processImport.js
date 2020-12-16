import { ImportRows } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ state, getters, commit }) => {
  state.settings.isProcessing = true

  function processImport () {
    if (state.settings.isProcessing) {
      ImportRows(state.dataset.id, {
        filter: state.paramsFilter.filter,
        start_id: state.startRow,
        retry_errored: state.settings.retryErrored
      }).then(response => {
        if (response.body.results.length) {
          response.body.results.forEach(row => {
            const position = getters[GetterNames.GetRowPositionById](row.id)
            if (position) {
              const payload = { pageIndex: position.pageIndex, rowIndex: position.rowIndex, row: row }
              commit(MutationNames.SetRow, payload)
            }
          })
          commit(MutationNames.SetStartRow, response.body.results.reduce((max, cur) => Math.max(max, cur.id), 0))
          delete response.body.results
          commit(MutationNames.SetDataset, response.body)

          processImport()
        } else {
          commit(MutationNames.SetStartRow, null)
          state.settings.isProcessing = false
        }
      }, () => {
        state.settings.isProcessing = false
      })
    } else {
      state.settings.isProcessing = false
    }
  }

  processImport()
}
