import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservationRows } from '../../request/resources'
import getPagination from 'helpers/getPagination.js'

export default function ({ commit, state }, params = {}) {
  return new Promise((resolve, reject) => {
    state.settings.loadingRows = true
    return GetMatrixObservationRows(state.matrix.id, Object.assign({}, params, state.configParams)).then(response => {
      commit(MutationNames.SetMatrixRows, response.body)
      commit(MutationNames.SetRowFixedPagination, getPagination(response))
      state.settings.loadingRows = false
      return resolve(response)
    }, (response) => {
      state.settings.loadingRows = false
      return reject(response)
    })
  })
}
