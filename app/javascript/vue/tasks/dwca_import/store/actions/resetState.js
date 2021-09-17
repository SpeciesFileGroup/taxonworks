import { makeInitialState } from '../store'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam.js'

export default ({ commit }) => {
  const initState = makeInitialState()

  commit(MutationNames.SetState, initState)
  SetParam(RouteNames.DwcImport, 'import_dataset_id')
}
