import { makeInitialState } from '../store.js'
import { EVENT_TAXON_DETERMINATION_FORM_RESET } from 'constants/index.js'

const resetTaxonDeterminationForm = () => {
  const event = new CustomEvent(EVENT_TAXON_DETERMINATION_FORM_RESET)
  document.dispatchEvent(event)
}

export default state => {
  const {
    preferences,
    project_preferences
  } = state

  history.replaceState(null, null, '/tasks/accessions/comprehensive')
  state = Object.assign(state, makeInitialState())
  state.preferences = preferences
  state.project_preferences = project_preferences

  resetTaxonDeterminationForm()
}
