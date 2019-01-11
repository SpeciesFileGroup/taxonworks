import { MutationNames } from '../mutations/mutations'
import { CreateCollectionObject, UpdateCollectionObject } from '../../request/resources'

export default function ({ commit, state }, co) {
  return new Promise((resolve, reject) => {
    let collection_object = co
    collection_object.collecting_event_id = state.collection_event.id
    commit(MutationNames.SetCollectionObjectPreparationId, state.preparation_type_id)
    if(collection_object.id) {
      UpdateCollectionObject(collection_object).then(response => {
        TW.workbench.alert.create('Collection object was successfully updated.', 'notice')
        return resolve(response)
      }, (response) => {
        return reject(response)
      })
    }
    else {
      CreateCollectionObject(collection_object).then(response => {
        TW.workbench.alert.create('Collection object was successfully created.', 'notice')
        return resolve(response)
      }, (response) => {
        return reject(response)
      })
    }
  })
}