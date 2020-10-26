import { GetDatasetRecords } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'
import { createEmptyPages } from '../../helpers/pages'
import Qs from 'qs'
import GetPagination from 'helpers/getPagination'

export default ({ state, commit, getters }, page) => {
  return new Promise((resolve, reject) => {
    const virtualPagination = getters[GetterNames.GetVirtualPages]
    const pagePosition = page === undefined ? 0 : page === 0 ? 1 : page - 1
    const currentPageOnVirtualPage = virtualPagination[state.currentPage] ? virtualPagination[state.currentPage].from + pagePosition : pagePosition
    const lastVirtualPage = virtualPagination[state.currentPage] ? virtualPagination[state.currentPage].to : undefined
    const loadPage = virtualPagination[state.currentPage] ? currentPageOnVirtualPage : pagePosition === 0 ? 1 : pagePosition

    if ((page !== undefined && state.datasetRecords[pagePosition] && (state.datasetRecords[pagePosition].downloaded || state.datasetRecords.rows)) || (loadPage && loadPage > lastVirtualPage)) return resolve()
    state.isLoading = true
    GetDatasetRecords(state.dataset.id, {
      params: Object.assign({}, { page: loadPage }, state.paramsFilter), paramsSerializer: (params) => Qs.stringify(params, { arrayFormat: 'brackets' })
    }).then(response => {
      commit(MutationNames.SetPagination, GetPagination(response))

      if (page === undefined) {
        page = 1
        commit(MutationNames.SetDatasetRecords, createEmptyPages(getters[GetterNames.GetVirtualPages][state.currentPage]))
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
