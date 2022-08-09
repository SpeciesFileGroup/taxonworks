import { OriginRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import parseOrigin from '../../helpers/parseOrigin'

export default ({ commit }, extract) => 
  OriginRelationship.where({ new_object_global_id: extract.global_id }).then(({ body }) => {
    commit(MutationNames.SetOriginRelationships, body.map(item => parseOrigin(item)))
  })

