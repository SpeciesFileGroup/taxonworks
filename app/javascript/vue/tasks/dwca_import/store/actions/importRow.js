import { ImportRows } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ state, getters, commit }, id) => {
  return new Promise((resolve, reject) => {
    ImportRows(state.dataset.id, { record_id: id }).then(response => {
      response.body.results.forEach(row => {
        const position = getters[GetterNames.GetRowPositionById](row.id)
        if (position) {
          const payload = { pageIndex: position.pageIndex, rowIndex: position.rowIndex, row: row }
          commit(MutationNames.SetRow, payload)
        }
      })
      delete response.body.results
      commit(MutationNames.SetDataset, response.body)
      resolve(response)
    }, (error) => {
      reject(error)
    })
  })
}
