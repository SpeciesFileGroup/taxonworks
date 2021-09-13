import { UpdateRow } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ state, commit, getters }, { rowId, data_fields }) => {
  UpdateRow(state.dataset.id, rowId, { data_fields: data_fields }).then(response => {
    const position = getters[GetterNames.GetRowPositionById](rowId)
    const payload = { pageIndex: position.pageIndex, rowIndex: position.rowIndex, row: response.body }
    commit(MutationNames.SetRow, payload)
  })
}
