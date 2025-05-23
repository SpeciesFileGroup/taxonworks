import { Container, CollectionObject } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, globalId) => {
  const request = Container.for({
    global_id: globalId,
    extend: ['container_items']
  })

  request
    .then(({ body }) => {
      commit(MutationNames.SetContainer, body)
      body.container_items.forEach((item) => {
        commit(MutationNames.AddContainerItem, item)

        CollectionObject.find(item.contained_object_id, {
          extend: ['dwc_occurrence']
        }).then(({ body }) => {
          commit(MutationNames.AddCollectionObject, body)
        })
      })
    })
    .catch(() => {})

  return request
}
