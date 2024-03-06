import { Citation } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  const promises = []

  async function createCitation(image) {
    const citation = {
      citation_object_id: image.id,
      citation_object_type: image.base_class,
      source_id: state.source.id,
      pages: undefined
    }

    return Citation.create({ citation }).then((response) => {
      commit(MutationNames.AddCitation, response.body)
    })
  }

  function citationAlreadyExistFor(image) {
    return state.citations.find(
      (citation) =>
        citation.citation_object_id === image.id &&
        state.source.id === citation.source_id
    )
  }

  state.imagesCreated.forEach((item) => {
    state.settings.saving = true

    if (state.source && !citationAlreadyExistFor(item)) {
      promises.push(createCitation(item))
    }
  })

  Promise.all(promises)
    .then(() => {
      TW.workbench.alert.create(
        `Citation(s) were successfully saved.`,
        'notice'
      )
    })
    .finally(() => {
      state.settings.saving = false
    })
}
