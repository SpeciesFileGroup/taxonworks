import { makeInitialState } from '../store'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam.js'

export default ({ state, commit }) => {
  const initState = makeInitialState()
  const { settings: { lock }, recents, preferences, extract } = state

  Object.entries(lock).forEach(([key, isLocked]) => {
    if (isLocked) {
      initState[key] = Array.isArray(state[key])
        ? state[key].map(item => ({ ...item, id: undefined }))
        : state[key]?.id ? { ...state[key], id: undefined } : state[key]
    }
  })

  if (lock.made) {
    initState.extract.day_made = extract.day_made
    initState.extract.month_made = extract.month_made
    initState.extract.year_made = extract.year_made
  }

  initState.recents = recents
  initState.preferences = preferences
  initState.settings.lock = lock

  commit(MutationNames.SetState, initState)
  SetParam(RouteNames.NewExtract, 'extract_id')
}
