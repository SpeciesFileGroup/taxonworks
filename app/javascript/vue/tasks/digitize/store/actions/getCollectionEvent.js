import { GetCollectionEvent } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
    GetCollectionEvent(id).then(response => {
      commit(MutationNames.SetCollectionEvent, response)
      if(state.collection_event.identifiers.length) {
        state.collectingEventIdentifier = state.collection_event.identifiers[0]
      }
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}