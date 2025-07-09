import { MutationNames } from '../mutations/mutations'
import { ContainerItem, CollectionObject } from '@/routes/endpoints'
import { useIdentifierStore } from '../pinia/identifiers'
import {
  CONTAINER,
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER
} from '@/constants'

export default async ({ commit, state }, coObject) => {
  const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
  const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()
  const containerItem = state.containerItems.find(
    (item) => item.contained_object_id === coObject.id
  )
  const promises = []

  if (state.container && !containerItem) {
    const item = {
      container_id: state.container.id,
      global_entity: coObject.global_id
    }

    const request = ContainerItem.create({ container_item: item })

    request.then(({ body }) => {
      commit(MutationNames.AddContainerItem, body)

      if (state.containerItems.length === 1) {
        const args = {
          objectType: CONTAINER,
          objectId: state.container.id,
          forceUpdate: true
        }

        promises.push(catalogNumber.save(args), recordNumber.save(args))
      }

      if (state.collection_object.id === body.contained_object_id) {
        const request = CollectionObject.find(body.contained_object_id, {
          extend: ['dwc_occurrence']
        })

        request.then((response) => {
          commit(MutationNames.SetCollectionObject, response.body)
        })

        promises.push(request)
      }
    })
  }

  return Promise.all(promises)
}
