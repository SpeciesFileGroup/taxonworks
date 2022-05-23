import { EVENT_TAXON_DETERMINATION_FORM_RESET } from 'constants/index.js'

const resetTaxonDeterminationForm = () => {
  const event = new CustomEvent(EVENT_TAXON_DETERMINATION_FORM_RESET)
  document.dispatchEvent(event)
}

export default ({ state }) => {
  state.taxon_determinations = state.settings.locked.taxonDeterminations
    ? state.taxon_determinations.map(item => 
        ({ 
          ...item,
          id: undefined,
          global_id: undefined,
          position: undefined 
        })
      )
    : []
  
  resetTaxonDeterminationForm()
}