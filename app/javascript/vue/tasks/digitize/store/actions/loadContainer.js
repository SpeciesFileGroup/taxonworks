import { Container, CollectionObject } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, globalId) =>
  Container.for(globalId).then(({ body }) => {
    commit(MutationNames.SetContainer, body)
    body.container_items.forEach((item) => {
      commit(MutationNames.AddContainerItem, item)

      CollectionObject.find(item.contained_object_id).then(({ body }) => {
        commit(MutationNames.AddCollectionObject, body)
      })
    })
  })
