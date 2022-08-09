import { MutationNames } from '../mutations/mutations'
import { ProtocolRelationship } from 'routes/endpoints'
import { EXTRACT } from 'constants/index.js'

export default ({ commit }, extract) => 
  ProtocolRelationship.where({ 
    protocol_relationship_object_id: extract.id,
    protocol_relationship_object_type: EXTRACT,
    extend: ['protocol']
  }).then(({ body }) => {
    commit(MutationNames.SetProtocols, body)
  })

