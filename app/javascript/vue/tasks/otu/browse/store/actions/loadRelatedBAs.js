import { BiologicalAssociation } from 'routes/endpoints'
import { OTU, COLLECTION_OBJECT } from 'constants/index.js'

export default ({ state }, objects) => {
  const payload = {
    collection_object_id: objects
      .filter((item) => COLLECTION_OBJECT === item.objectType)
      .map((item) => item.objectId),
    otu_id: objects
      .filter((item) => OTU === item.subjectType)
      .map((item) => item.subjectId)
  }

  return BiologicalAssociation.all(payload).then(({ body }) => {
    state.relatedBAs = state.relatedBAs.concat(body)
  })
}
