import { GetOriginRelationships } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, extract) => {
  GetOriginRelationships({ new_object_global_id: extract.global_id }).then(({ body }) => {
    const [originRelationship] = body

    commit(MutationNames.SetOriginRelationship, originRelationship
      ? {
          id: originRelationship.id,
          newObject: { ...originRelationship.new_object, new_object_type: originRelationship.new_object_type },
          oldObject: { ...originRelationship.old_object, old_object_type: originRelationship.old_object_type },
          object_tag: originRelationship.old_object_object_tag
        }
      : {}
    )
  })
}
