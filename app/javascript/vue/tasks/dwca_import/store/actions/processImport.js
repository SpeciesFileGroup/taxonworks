import { ImportRows, StopImport } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'
import { createEmptyPages } from '../../helpers/pages'

export default ({ state, getters, commit }) => {
  state.settings.isProcessing = true
  state.settings.stopRequested = false

  function processImport () {
    if (state.settings.isProcessing) {
      ImportRows(state.dataset.id, {
        filter: state.paramsFilter.filter,
        start_id: state.startRow,
        retry_errored: state.settings.retryErrored,
        containerize_dup_cat_no: !!state.dataset.metadata.import_settings?.containerize_dup_cat_no
      }).then(response => {
        if (response.body.results.length) {
          response.body.results.forEach(row => {
            const position = getters[GetterNames.GetRowPositionById](row.id)
            if (position) {
              const payload = { pageIndex: position.pageIndex, rowIndex: position.rowIndex, row: row }
              commit(MutationNames.SetRow, payload)
            }
          })
          delete response.body.results
          commit(MutationNames.SetDataset, response.body)

          if (state.settings.stopRequested) {
            StopImport(state.dataset.id, {
              filter: state.paramsFilter.filter
            }).then(response => {
              commit(MutationNames.SetDataset, response.body)
              commit(MutationNames.SetDatasetRecords, createEmptyPages(getters[GetterNames.GetVirtualPages][state.currentPage]))
            }).finally(() => {
              state.settings.isProcessing = false
            })
          } else {
            processImport()
          }
        } else {
          commit(MutationNames.SetDatasetRecords, createEmptyPages(getters[GetterNames.GetVirtualPages][state.currentPage]))
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
