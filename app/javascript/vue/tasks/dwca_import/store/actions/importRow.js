import { MutationNames } from '../mutations/mutations'
import { ActionNames } from '../actions/actions'
import { GetterNames } from '../getters/getters'
import { ImportDataset } from '@/routes/endpoints'
import { IMPORT_DATASET_DWC_CHECKLIST } from '@/constants'

export default async ({ state, getters, commit, dispatch }, id) => {
  return ImportDataset.importRows(state.dataset.id, { record_id: id })
    .then((response) => {
      const { results, ...data } = response.body

      if (state.dataset.type === IMPORT_DATASET_DWC_CHECKLIST) {
        state.datasetRecords.forEach((p) => {
          p.downloaded = false
        })

        dispatch(ActionNames.LoadDatasetRecords)

        return
      }

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
