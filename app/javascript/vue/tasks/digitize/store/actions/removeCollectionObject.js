import { MutationNames } from '../mutations/mutations'
import { CollectionObject } from 'routes/endpoints'
import { ActionNames } from './actions'

export default ({ commit, dispatch, state }, id) =>
  CollectionObject.destroy(id).then(() => {
    const containerItem = state.containerItems.find(item => item.contained_object_id === id)

    commit(MutationNames.RemoveCollectionObject, id)

    if (containerItem) {
      commit(MutationNames.RemoveContainerItem, containerItem.id)
    }
    if (state.collection_object.id === id) {
      dispatch(ActionNames.NewCollectionObject)
    }

    const coCount = state.collection_objects.length

    if (coCount === 1) {
      dispatch(ActionNames.RemoveContainer).then(_ => {
        const containerItems = state.containerItems.slice()
        const identifier = state.identifiers[0]
        const co = state.collection_objects[0].id

        containerItems.forEach(item => {
          if (item.contained_object_id !== id) {
            dispatch(ActionNames.RemoveContainerItem, item.id)
          } else {
            commit(MutationNames.RemoveContainerItem, item.id)
          }
        })

        state.identifiers = []

        if (identifier) {
          commit(MutationNames.SetIdentifier, {
            identifier: identifier.identifier,
            identifier_object_id: co.id,
            namespace_id: identifier.namespace_id,
            type: 'Identifier::Local::CatalogNumber'
          })
        }
        dispatch(ActionNames.SaveIdentifier, state.collection_objects[0].id)
      })
    }
  })
