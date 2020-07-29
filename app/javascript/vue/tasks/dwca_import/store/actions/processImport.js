import { ImportRows } from '../../request/resources'
import { ActionNames } from './actions'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ state, getters, commit, dispatch }) => {
  state.settings.isProcessing = true

  function processImport () {
    if (state.settings.isProcessing) {
      ImportRows(state.dataset.id).then(response => {
        if (response.body.results.length) {
          response.body.results.forEach(row => {
            const payload = { index: getters[GetterNames.GetRowPositionById](row.id), row: row }
            commit(MutationNames.SetRow, payload)
          })
          delete response.body.results
          commit(MutationNames.SetDataset, response.body)

          processImport()
        } else {
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
