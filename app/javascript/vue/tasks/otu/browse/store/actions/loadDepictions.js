import { OTU } from '@/constants'
import { MutationNames } from '../mutations/mutations'
import { Depiction } from '@/routes/endpoints'

export default ({ commit, state }, id) => {
  Depiction.where({
    depiction_object_id: id,
    depiction_object_type: OTU,
    per: 500
  }).then((response) => {
    commit(MutationNames.SetDepictions, state.depictions.concat(response.body))
  })
}
