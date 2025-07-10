import { MutationNames } from '../mutations/mutations'
import { CollectionObject } from '@/routes/endpoints'
import { ActionNames } from './actions'

export default ({ commit, dispatch, state }, id) =>
  CollectionObject.destroy(id).then(() => {
    const containerItem = state.containerItems.find(
      (item) => item.contained_object_id === id
    )

    commit(MutationNames.RemoveCollectionObject, id)

    if (containerItem) {
      commit(MutationNames.RemoveContainerItem, containerItem.id)
    }
    if (state.collection_object.id === id) {
      dispatch(ActionNames.NewCollectionObject)
    }

    const coCount = state.collection_objects.length

    if (coCount === 1) {
      dispatch(ActionNames.RemoveContainer).then((_) => {
        const containerItems = state.containerItems.slice()

        containerItems.forEach((item) => {
          if (item.contained_object_id !== id) {
            dispatch(ActionNames.RemoveContainerItem, item.id)
          } else {
            commit(MutationNames.RemoveContainerItem, item.id)
          }
        })

        state.identifiers = []
      })
    }
  })
