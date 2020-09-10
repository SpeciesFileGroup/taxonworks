import { GetDatasetRecords } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { createEmptyPages } from '../../helpers/pages'
import Qs from 'qs'
import GetPagination from 'helpers/getPagination'

export default ({ state, commit }, page) => {
  if (page !== undefined && state.datasetRecords[page] && (state.datasetRecords[page].downloaded || state.datasetRecords.rows)) return
  state.isLoading = true
  GetDatasetRecords(state.dataset.id, {
    params: Object.assign({}, { page: page }, state.paramsFilter), paramsSerializer: (params) => Qs.stringify(params, { arrayFormat: 'brackets' })
  }).then(response => {
    commit(MutationNames.SetPagination, GetPagination(response))

    if (page === undefined) {
      page = 0
      commit(MutationNames.SetDatasetRecords, createEmptyPages(state.pagination))
    }
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
