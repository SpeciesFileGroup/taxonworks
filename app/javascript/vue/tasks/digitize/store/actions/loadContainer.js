import { GetContainer, GetCollectionObject } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, globalId) {
  return new Promise((resolve, reject) => {
    GetContainer(globalId).then(response => {
      commit(MutationNames.SetContainer, response.body)
      response.body.container_items.forEach(item => {
        commit(MutationNames.AddContainerItem, item.container_item)
        GetCollectionObject(item.container_item.contained_object_id).then(response => {
          commit(MutationNames.AddCollectionObject, response.body)
        })
      })
      resolve(response.body)
    }).catch(error => {})
  })
}