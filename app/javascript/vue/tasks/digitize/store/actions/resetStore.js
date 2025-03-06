import { makeInitialState } from '../store.js'
import { useIdentifierStore, useTaxonDeterminationStore } from '../pinia'
import {
  EVENT_TAXON_DETERMINATION_FORM_RESET,
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  IDENTIFIER_LOCAL_RECORD_NUMBER
} from '@/constants/index.js'

const resetTaxonDeterminationForm = () => {
  const event = new CustomEvent(EVENT_TAXON_DETERMINATION_FORM_RESET)
  document.dispatchEvent(event)
}

export default ({ state }) => {
  const { preferences, project_preferences } = state
  const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
  const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
  const determinationStore = useTaxonDeterminationStore()

  history.replaceState(null, null, '/tasks/accessions/comprehensive')
  state = Object.assign(state, makeInitialState())
  state.preferences = preferences
  state.project_preferences = project_preferences
  recordNumber.$reset()
  catalogNumber.$reset()
  determinationStore.$reset()

  resetTaxonDeterminationForm()
}
