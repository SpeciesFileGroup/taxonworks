import { Citation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { COLLECTION_OBJECT } from 'constants/index.js'

export default ({ state: { collection_object, settings, coCitations }, commit }) => {
  const lockCOCitations = settings.locked.coCitations

  Citation.where({
    citation_object_type: COLLECTION_OBJECT,
    citation_object_id: collection_object.id
  }).then(({ body }) => {
    if (lockCOCitations) {
      const currentCitations = coCitations
      const currentCitationsSourceId = currentCitations.map(citation => citation.source_id)

      body.forEach(citation => {
        const index = currentCitationsSourceId.findIndex(id => id === citation.source_id)

        if (index > -1) {
          currentCitations[index] = citation
        } else {
          currentCitations.push(citation)
        }
      })

      commit(MutationNames.SetCOCitations, currentCitations)
    } else {
      commit(MutationNames.SetCOCitations, body)
    }
  })
}
