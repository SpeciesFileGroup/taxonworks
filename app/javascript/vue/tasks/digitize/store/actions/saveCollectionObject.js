import { MutationNames } from '../mutations/mutations'
import { CreateCollectionObject, UpdateCollectionObject } from '../../request/resources'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let collection_object = state.collection_object
    collection_object.collecting_event_id = state.collection_event.id
    if(collection_object.id) {
      UpdateCollectionObject(collection_object).then(response => {
        TW.workbench.alert.create('Collection object was successfully updated.', 'notice')
        commit(MutationNames.SetCollectionObject, response)
        return resolve(response)
      }, (response) => {
        return reject(response)
      })
    }
    else {
      CreateCollectionObject(collection_object).then(response => {
        TW.workbench.alert.create('Collection object was successfully created.', 'notice')
        commit(MutationNames.SetCollectionObject, response)
        return resolve(response)
      }, (response) => {
        return reject(response)
      })
    }
  })
}