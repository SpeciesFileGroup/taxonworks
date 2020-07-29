import { GetDatasetRecords } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import Qs from 'qs'
import GetPagination from 'helpers/getPagination'

export default ({ state, commit }, page = undefined) => {
  state.isLoading = true
  GetDatasetRecords(state.dataset.id, { params: Object.assign({}, { page: page }, state.paramsFilter), paramsSerializer: (params) => Qs.stringify(params, { arrayFormat: 'brackets' }) }).then(response => {
    commit(MutationNames.SetPagination, GetPagination(response))
    commit(MutationNames.SetDatasetRecords, page ? state.datasetRecords.concat(response.body) : response.body)
    state.isLoading = false
  }, () => {
    state.isLoading = false
  })
}
