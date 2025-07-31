import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'
import { ImportDataset } from '@/routes/endpoints'

export default ({ state, getters, commit }, id) => {
  return ImportDataset.importRows(state.dataset.id, { record_id: id })
    .then((response) => {
      const { results, ...data } = response.body

      results.forEach((row) => {
        const position = getters[GetterNames.GetRowPositionById](row.id)

        if (position) {
          const payload = {
            pageIndex: position.pageIndex,
            rowIndex: position.rowIndex,
            row
          }

          commit(MutationNames.SetRow, payload)
        }
      })

      commit(MutationNames.SetDataset, data)
    })
    .catch(() => {})
}
