import { makeInitialState } from '../store'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam.js'

export default ({ state, commit }) => {
  const initState = makeInitialState()
  const { settings: { lock }, recents } = state

  Object.entries(lock).forEach(([key, isLocked]) => {
    if (isLocked) {
      initState[key] = Array.isArray(state[key])
        ? state[key].map(item => ({ ...item, id: undefined }))
        : state[key]
    }
  })

  initState.recents = recents

  commit(MutationNames.SetState, initState)
  SetParam(RouteNames.NewExtract, 'extract_id')
}
