import { Container, CollectionObject } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, globalId) =>
  new Promise((resolve, reject) => {
    Container.for(globalId).then(response => {
      commit(MutationNames.SetContainer, response.body)
      response.body.container_items.forEach(item => {
        commit(MutationNames.AddContainerItem, item.container_item)
        CollectionObject.find(item.container_item.contained_object_id).then(response => {
          commit(MutationNames.AddCollectionObject, response.body)
        })
      })
      resolve(response)
    }, response => {
      reject(response)
    })
  })
