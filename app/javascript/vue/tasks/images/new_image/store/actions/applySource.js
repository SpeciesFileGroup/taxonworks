import { Citation } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  const promises = []

  async function createCitation(image) {
    const citation = {
      citation_object_id: image.id,
      citation_object_type: image.base_class,
      source_id: state.source.id,
      is_original: state.isOriginal,
      pages: undefined
    }

    return Citation.create({ citation }).then((response) => {
      commit(MutationNames.AddCitation, response.body)
      commit(MutationNames.MarkApplied, {
        imageIds: [image.id],
        key: 'source'
      })
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

    if (state.source) {
      if (citationAlreadyExistFor(item)) {
        commit(MutationNames.MarkApplied, {
          imageIds: [item.id],
          key: 'source'
        })
      } else {
        promises.push(createCitation(item))
      }
    }
  })

  return Promise.all(promises)
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
