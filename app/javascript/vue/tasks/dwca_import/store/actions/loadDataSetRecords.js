import { GetDatasetRecords } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import Qs from 'qs'
import GetPagination from 'helpers/getPagination'

export default ({ state, commit }, page = 1) => {
  if (state.datasetRecords[page] && (state.datasetRecords[page].downloaded || state.datasetRecords.rows)) return
  state.isLoading = true
  GetDatasetRecords(state.dataset.id, {
    params: Object.assign({}, { page: page }, state.paramsFilter), paramsSerializer: (params) => Qs.stringify(params, { arrayFormat: 'brackets' })
  }).then(response => {
    commit(MutationNames.SetPagination, GetPagination(response))
    commit(MutationNames.SetDatasetPage, {
      pageNumber: page,
      page: {
        count: response.body.length,
        downloaded: true,
        rows: response.body
      }
    })
    state.isLoading = false
  }, () => {
    state.isLoading = false
  })
}
