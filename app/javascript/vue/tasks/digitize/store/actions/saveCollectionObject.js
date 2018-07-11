import { MutationNames } from '../mutations/mutations'
import { CreateCollectionObject, UpdateCollectionObject } from '../../request/resources'

export default function ({ commit, state }) {
  return new Promise((resolve, rejected) => {
    let collection_object = state.collection_object
    console.log(collection_object)
    if(collection_object.id) {
      UpdateCollectionObject(collection_object).then(response => {
        TW.workbench.alert.create('Collection object was successfully updated.', 'notice')
        commit(MutationNames.SetCollectionObject, response)
        return resolve(response)
      })
    }
    else {
      CreateCollectionObject(collection_object).then(response => {
        TW.workbench.alert.create('Collection object was successfully created.', 'notice')
        commit(MutationNames.SetCollectionObject, response)
        return resolve(response)
      })
    }
  }, (response) => {
    return rejected(response)
  })
}