import { ActionNames } from '../store/actions/actions'
import { useStore } from 'vuex'

export default (citation) => {
  const store = useStore()
  const TIME_DELAY = 3000
  let autosaveTimeout = undefined

  const updateCitation = () => {
    store.dispatch(ActionNames.UpdateCitation, {
      citationId: citation.id,
      is_original: citation.is_original,
      pages: citation.pages,
      type: citation.citation_object_type
    })
  }

  const autosaveCitation = () => {
    if (autosaveTimeout) {
      clearTimeout(autosaveTimeout)
    }
    autosaveTimeout = setTimeout(() => {
      updateCitation()
    }, TIME_DELAY)
  }

  const removeCitation = () => {
    if (window.confirm('You\'re about to delete this citation record. Are you sure want to proceed?')) {
      store.dispatch(ActionNames.RemoveCitation, {
        citationId: citation.id,
        type: citation.citation_object_type
      })
    }
  }

  return {
    autosaveCitation,
    removeCitation,
    updateCitation
  }
}