import { Identifier } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, { objectType, id }) => {
  Identifier.where({
    identifier_object_id: id,
    identifier_object_type: objectType
  }).then(({ body }) => {
    body.map((item) =>
      commit(MutationNames.AddIdentifier, { objectType, item })
    )
  })
}
