import { MutationNames } from '../mutations/mutations'
import { CreateCollectionEvent, UpdateCollectionEvent } from '../../request/resources'
import CollectingEvent from '../../const/collectingEvent'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let collection_event = state.collection_event
    if(JSON.stringify(CollectingEvent()) == JSON.stringify(collection_event)) {
      return resolve(true)
    }
    else {
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
    }
  })
}