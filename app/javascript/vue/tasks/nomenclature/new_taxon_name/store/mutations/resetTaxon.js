import { makeInitialState } from '../initialState'

export default function (state) {
  const initialState = makeInitialState()
  const { allRanks, status, relationships, settings } = state

  Object.assign(state, initialState, {
    allRanks,
    status,
    relationships,
    settings: {
      ...initialState.settings,
      initLoad: settings.initLoad,
      autosave: settings.autosave
    }
  })
}
