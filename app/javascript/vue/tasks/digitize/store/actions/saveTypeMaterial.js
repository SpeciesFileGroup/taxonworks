import { MutationNames } from '../mutations/mutations'
import { CreateCollectionObject, UpdateCollectionObject } from '../../request/resources'

export default function ({ commit, state }) {
  return new Promise((resolve, rejected) => {
    let type_material = state.type_material
    type_material.collection_object = state.collection_object
    if(type_material.id) {
      UpdateCollectionObject(type_material).then(response => {
        TW.workbench.alert.create('Collection object was successfully updated.', 'notice')
        commit(MutationNames.SetTypeMaterial, response)
        return resolve(response)
      })
    }
    else {
      CreateCollectionObject(type_material).then(response => {
        TW.workbench.alert.create('Collection object was successfully created.', 'notice')
        commit(MutationNames.SetTypeMaterial, response)
        return resolve(response)
      })
    }
  }, (response) => {
    return rejected(response)
  })
}