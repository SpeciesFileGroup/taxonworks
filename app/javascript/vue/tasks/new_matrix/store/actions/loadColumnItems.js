import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservationColumns } from '../../request/resources'
import getPagination from 'helpers/getPagination.js'

export default function ({ commit, state }, params = {}) {
  return new Promise((resolve, reject) => {
    state.settings.loadingColumns = true
    return GetMatrixObservationColumns(state.matrix.id, Object.assign({}, params, state.configParams)).then(response => {
      commit(MutationNames.SetMatrixColumns, response.body)
      commit(MutationNames.SetColumnFixedPagination, getPagination(response))
      state.settings.loadingColumns = false
      return resolve(response)
    }, (response) => {
      state.settings.loadingColumns = false
      return reject(response)
    })
  })
}
