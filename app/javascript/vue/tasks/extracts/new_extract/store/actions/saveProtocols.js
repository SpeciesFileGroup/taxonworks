import { MutationNames } from '../mutations/mutations'
import { CreateProtocol } from '../../request/resources'

export default ({ state, commit }) => {
  const promises = []
  const newProtocols = state.protocols.filter(item => !item.id)

  newProtocols.forEach(item => {
    promises.push(CreateProtocol(item).then(({ body }) => {
      commit(MutationNames.AddIdentifier, body)
    }))
  })
}
