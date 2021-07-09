import { ContainerItem } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  ContainerItem.destroy(id).then(_ => {
    commit(MutationNames.RemoveContainerItem, id)
  })
}
