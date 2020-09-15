import { GetDatasetRecords } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { createEmptyPages } from '../../helpers/pages'
import Qs from 'qs'
import GetPagination from 'helpers/getPagination'

export default ({ state, commit }, page) => {
  return new Promise((resolve, reject) => {
    const pagePosition = page === undefined ? undefined : page === 0 ? 1 : page - 1
    if (page !== undefined && state.datasetRecords[pagePosition] && (state.datasetRecords[pagePosition].downloaded || state.datasetRecords.rows)) return resolve()
    state.isLoading = true
    GetDatasetRecords(state.dataset.id, {
      params: Object.assign({}, { page: page }, state.paramsFilter), paramsSerializer: (params) => Qs.stringify(params, { arrayFormat: 'brackets' })
    }).then(response => {
      commit(MutationNames.SetPagination, GetPagination(response))

      if (page === undefined) {
        page = 1
        commit(MutationNames.SetDatasetRecords, createEmptyPages(state.pagination))
      }
      page = page - 1
      commit(MutationNames.SetDatasetPage, {
        pageNumber: page,
        page: {
          count: response.body.length,
          downloaded: true,
          rows: response.body
        }
      })
      state.isLoading = false
      resolve(response)
    }, (error) => {
      state.isLoading = false
      reject(error)
    })
  })
}
