import { CreateOriginRelationship, UpdateOriginRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  const { extract, originRelationship } = state
  const saveFn = originRelationship.id ? UpdateOriginRelationship : CreateOriginRelationship

  const data = Object.assign({}, originRelationship, {
    new_object_type: 'Extract',
    new_object_id: extract.id
  })

  if (originRelationship.old_object_id) {
    saveFn(data).then(({ body }) => {
      commit(MutationNames.SetOriginRelationship, body)
    })
  }
}
