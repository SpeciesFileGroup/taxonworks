import { OriginRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import parseOrigin from '../../helpers/parseOrigin'

export default ({ state: { extract, originRelationship }, commit }) => {
  if (!originRelationship.oldObject) return

  const data = {
    id: originRelationship.id,
    old_object_id: originRelationship.oldObject.old_object_id,
    old_object_type: originRelationship.oldObject.old_object_type,
    new_object_type: 'Extract',
    new_object_id: extract.id
  }

  const saveOriginRelationshio = originRelationship.id
    ? OriginRelationship.update(originRelationship.id, { origin_relationship: data })
    : OriginRelationship.create({ origin_relationship: data })

  saveOriginRelationshio.then(({ body }) => {
    commit(MutationNames.SetOriginRelationship, parseOrigin(body))
  })
}
