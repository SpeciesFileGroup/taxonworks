import { CreateOriginRelationship, UpdateOriginRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  const { extract, originRelationship } = state
  const saveFn = originRelationship.id ? UpdateOriginRelationship : CreateOriginRelationship

  if (!originRelationship.oldObject) return

  const data = {
    id: originRelationship.id,
    old_object_id: originRelationship.oldObject.old_object_id,
    old_object_type: originRelationship.oldObject.old_object_type,
    new_object_type: 'Extract',
    new_object_id: extract.id
  }

  saveFn(data).then(({ body }) => {
    commit(MutationNames.SetOriginRelationship, body)
  })
}
