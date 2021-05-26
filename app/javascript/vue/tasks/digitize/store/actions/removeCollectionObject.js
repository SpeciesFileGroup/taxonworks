import { MutationNames } from '../mutations/mutations'
import { CollectionObject } from 'routes/endpoints'
import ActionNames from './actionNames'

export default ({ commit, dispatch, state }, id) =>
  CollectionObject.destroy(id).then(() => {
    commit(MutationNames.RemoveCollectionObject, id)
    if (state.collection_object.id === id) {
      dispatch(ActionNames.NewCollectionObject)
    }
  })
