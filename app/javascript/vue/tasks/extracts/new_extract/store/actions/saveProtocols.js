import { MutationNames } from '../mutations/mutations'
import { ProtocolRelationship } from 'routes/endpoints'

export default ({ state, commit }) => {
  const { extract, protocols } = state
  const promises = []
  const newProtocols = protocols.filter(item => !item.id)

  newProtocols.forEach(item => {
    promises.push(ProtocolRelationship.create({
      protocol_relationship: {
        ...item,
        protocol_relationship_object_id: extract.id,
        protocol_relationship_object_type: 'Extract'
      },
      extend: ['protocol']
    }).then(({ body }) => {
      commit(MutationNames.AddProtocol, body)
    }))
  })
}
