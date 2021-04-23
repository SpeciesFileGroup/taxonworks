import { MutationNames } from '../mutations/mutations'
import { CreateProtocol } from '../../request/resources'

export default ({ state, commit }) => {
  const { extract, protocols } = state
  const promises = []
  const newProtocols = protocols.filter(item => !item.id)
  console.log(newProtocols)
  newProtocols.forEach(item => {
    promises.push(CreateProtocol({
      ...item,
      protocol_relationship_object_id: extract.id,
      protocol_relationship_object_type: 'Extract'
    }).then(({ body }) => {
      commit(MutationNames.AddProtocol, body)
    }))
  })
}
