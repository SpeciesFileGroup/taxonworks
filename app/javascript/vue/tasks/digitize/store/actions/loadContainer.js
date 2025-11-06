import { Container, CollectionObject } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { CONTAINER_VIAL, CONTAINER_VIRTUAL, CONTAINER_PIN } from '@/constants'

const ALLOWED_CONTAINERS = [CONTAINER_VIAL, CONTAINER_VIRTUAL, CONTAINER_PIN]

export default async ({ commit }, globalId) => {
  try {
    const { body } = await Container.for({
      global_id: globalId,
      extend: ['container_items']
    })

    if (!ALLOWED_CONTAINERS.includes(body.type)) {
      throw new Error('Not allowed container type')
    }

    const coIds = body.container_items.map((item) => item.contained_object_id)

    commit(MutationNames.SetContainer, body)

    body.container_items.forEach((item) =>
      commit(MutationNames.AddContainerItem, item)
    )

    const { body: coBody } = await CollectionObject.where({
      collection_object_id: coIds,
      extend: ['dwc_occurrence']
    })

    commit(MutationNames.SetCollectionObjects, coBody)

    return body
  } catch (error) {
    throw error
  }
}
