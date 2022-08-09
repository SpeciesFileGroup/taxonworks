import { OriginRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { EXTRACT } from 'constants/index.js'
import parseOrigin from '../../helpers/parseOrigin'

export default ({ state: { extract, originRelationships }, commit }) => {
  const unsavedRelationships = originRelationships.filter(item => item.isUnsaved)

  const saveRequests = unsavedRelationships.map(relationship => {
    const data = {
      id: relationship.id,
      old_object_id: relationship.old_object_id,
      old_object_type: relationship.old_object_type,
      new_object_type: EXTRACT,
      new_object_id: extract.id
    }

    return relationship.id
      ? OriginRelationship.update(data.id, { origin_relationship: data })
      : OriginRelationship.create({ origin_relationship: data })
  })

  Promise.all(saveRequests).then(responses => {
    const savedRelationships = responses.map(({ body }) => parseOrigin(body))

    commit(MutationNames.SetOriginRelationships, [
      ...savedRelationships,
      ...originRelationships.filter(item => !item.isUnsaved)
    ])
  })
}
