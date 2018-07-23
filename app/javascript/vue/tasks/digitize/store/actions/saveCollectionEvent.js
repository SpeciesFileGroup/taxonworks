import { MutationNames } from '../mutations/mutations'
import { CreateCollectionEvent, UpdateCollectionEvent } from '../../request/resources'

export default function ({ commit, state }) {
  return new Promise((resolve, rejected) => {
    let collection_event = state.collection_event
    if(collection_event.id) {
      UpdateCollectionEvent(collection_event).then(response => {
        TW.workbench.alert.create('Collection object was successfully updated.', 'notice')
        commit(MutationNames.SetCollectionEvent, response)
        return resolve(response)
      })
    }
    else {
      CreateCollectionEvent(collection_event).then(response => {
        TW.workbench.alert.create('Collection object was successfully created.', 'notice')
        commit(MutationNames.SetCollectionEvent, response)
        return resolve(response)
      })
    }
  }, (response) => {
    return rejected(response)
  })
}