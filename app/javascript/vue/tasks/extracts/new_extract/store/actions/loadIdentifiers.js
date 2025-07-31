import { EXTRACT } from '@/constants'
import { MutationNames } from '../mutations/mutations'
import { Identifier } from '@/routes/endpoints'

export default ({ commit, state: { extract } }) => {
  return Identifier.where({
    identifier_object_id: extract.id,
    identifier_object_type: EXTRACT
  }).then(({ body }) => {
    commit(MutationNames.SetIdentifiers, body)
  })
}
