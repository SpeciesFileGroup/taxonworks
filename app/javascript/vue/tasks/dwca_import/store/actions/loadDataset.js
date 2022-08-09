import ActionNames from './actionNames'
import { GetDataset } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import SetParam from 'helpers/setParam'
import { RouteNames } from 'routes/routes'

export default ({ state, commit, dispatch }, id) => {
  return new Promise((resolve, reject) => {
    GetDataset(id).then(({ body }) => {
      const {
        import_filters,
        import_retry_errored
      } = body?.metadata || {}

      const importRunning = !!import_filters

      SetParam(RouteNames.DwcImport, 'import_dataset_id', id)
      commit(MutationNames.SetDataset, body)

      if (importRunning) {
        commit(MutationNames.SetParamsFilter, Object.assign({}, state.paramsFilter, { filter: import_filters }))
        commit(MutationNames.SetSettings, Object.assign({}, state.settings, { retryErrored: !!import_retry_errored, importModalView: true }))
        dispatch(ActionNames.ProcessImport)
      }

      resolve(body)
    }, (error) => {
      reject(error)
    })
  })
}
