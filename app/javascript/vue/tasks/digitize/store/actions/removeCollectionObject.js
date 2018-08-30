import { MutationNames } from '../mutations/mutations'
import { DestroyCollectionObject } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
    DestroyCollectionObject(id).then(response => {
      commit(MutationNames.RemoveCollectionObject, id)
      if(state.collection_object.id == id) {
        commit(MutationNames.NewCollectionObject)
      }
    })
  })
}