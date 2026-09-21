import { makeInitialState } from '../initialState'

// Returns the task to the "new taxon name" state without reloading the page.
// The lists loaded once on init (ranks, status, relationships) and the task
// settings the user already chose (autosave) are kept. Everything derived from
// the taxon or its parent, `allRanks` included, goes back to its initial value.
export default function (state) {
  const initialState = makeInitialState()
  const { ranks, status, relationships, settings } = state

  Object.assign(state, initialState, {
    ranks,
    status,
    relationships,
    settings: {
      ...initialState.settings,
      initLoad: settings.initLoad,
      autosave: settings.autosave
    }
  })
}
