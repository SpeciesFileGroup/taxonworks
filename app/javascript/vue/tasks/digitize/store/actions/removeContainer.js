import { Container } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) =>
  Container.destroy(state.container.id).then(_ => {
    commit(MutationNames.SetContainer, undefined)
  })
