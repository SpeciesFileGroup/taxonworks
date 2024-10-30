import { MutationNames } from '../mutations/mutations'
import { ContainerItem, CollectionObject } from '@/routes/endpoints'
import { useIdentifierStore } from '../pinia/identifiers'
import {
  CONTAINER,
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER
} from '@/constants'

export default ({ commit, state }) =>
  new Promise((resolve, reject) => {
    const catalogNumber = useIdentifierStore(IDENTIFIER_LOCAL_CATALOG_NUMBER)()
    const recordNumber = useIdentifierStore(IDENTIFIER_LOCAL_RECORD_NUMBER)()

    if (
      state.container &&
      !state.containerItems.find(
        (item) => item.contained_object_id === state.collection_object.id
      )
    ) {
      const item = {
        container_id: state.container.id,
        global_entity: state.collection_object.global_id
      }

      ContainerItem.create({ container_item: item }).then(({ body }) => {
        commit(MutationNames.AddContainerItem, body)

        if (state.containerItems.length === 1) {
          const args = {
            objectType: CONTAINER,
            objectId: state.container.id,
            forceUpdate: true
          }

          catalogNumber.save(args)
          recordNumber.save(args)
        }
        if (state.collection_object.id === body.contained_object_id) {
          CollectionObject.find(body.contained_object_id).then((response) => {
            commit(MutationNames.SetCollectionObject, response.body)
          })
        }
        return resolve(body)
      })
    }
  })
