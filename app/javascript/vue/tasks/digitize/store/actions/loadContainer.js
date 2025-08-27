import { Container, CollectionObject } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, globalId) => {
  const request = Container.for({
    global_id: globalId,
    extend: ['container_items']
  })

  request
    .then(({ body }) => {
      const coIds = body.container_items.map((item) => item.contained_object_id)

      commit(MutationNames.SetContainer, body)

      body.container_items.forEach((item) =>
        commit(MutationNames.AddContainerItem, item)
      )

      CollectionObject.where({
        collection_object_id: coIds,
        extend: ['dwc_occurrence']
      }).then(({ body }) => {
        commit(MutationNames.SetCollectionObjects, body)
      })
    })
    .catch(() => {})

  return request
}
