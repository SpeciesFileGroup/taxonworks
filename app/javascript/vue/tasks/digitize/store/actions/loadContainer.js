import { Container, CollectionObject } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { CONTAINER_VIAL, CONTAINER_VIRTUAL, CONTAINER_PIN } from '@/constants'

const ALLOWED_CONTAINERS = [CONTAINER_VIAL, CONTAINER_VIRTUAL, CONTAINER_PIN]

export default ({ commit }, globalId) => {
  const request = Container.for({
    global_id: globalId,
    extend: ['container_items']
  })

  request
    .then(({ body }) => {
      if (!ALLOWED_CONTAINERS.includes(body.type)) {
        return Promise.reject()
      }

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
