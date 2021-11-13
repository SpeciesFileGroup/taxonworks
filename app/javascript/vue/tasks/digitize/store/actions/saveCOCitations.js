import { MutationNames } from '../mutations/mutations'
import { Citation } from 'routes/endpoints'

export default ({ commit, state: { coCitations, collection_object } }) => {
  const promises = []

  coCitations.forEach(citation => {
    if (citation.id) {
      if (citation.citation_object_id !== collection_object.id) {
        citation.id = undefined
        citation.citation_object_id = collection_object.id
        promises.push(Citation.create({ citation }))
      } else {
        promises.push(Promise.resolve({ body: citation }))
      }
    } else {
      citation.citation_object_id = collection_object.id
      promises.push(Citation.create({ citation }))
    }
  })

  Promise.all(promises).then(responses => {
    commit(MutationNames.SetCOCitations, responses.map(({ body }) => body))
  })
}
