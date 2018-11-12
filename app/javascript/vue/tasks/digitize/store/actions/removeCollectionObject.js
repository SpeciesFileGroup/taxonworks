import { MutationNames } from '../mutations/mutations'
import { DestroyCollectionObject } from '../../request/resources'
import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }, id) {
  return new Promise((resolve, reject) => {
    DestroyCollectionObject(id).then(response => {
      commit(MutationNames.RemoveCollectionObject, id)
      if(state.collection_object.id == id) {
        dispatch(ActionNames.NewCollectionObject)
      }
    })
  })
}