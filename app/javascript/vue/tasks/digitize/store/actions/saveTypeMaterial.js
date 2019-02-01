import { MutationNames } from '../mutations/mutations'
import { UpdateTypeMaterial, CreateTypeMaterial } from '../../request/resources'
import ValidateTypeMaterial from '../../validations/typeMaterial'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    commit(MutationNames.SetTypeMaterialBiologicalObjectId, state.collection_object.id)
    let type_material = state.type_material
    if(ValidateTypeMaterial(type_material)) {
      if(type_material.id) {
        UpdateTypeMaterial(type_material).then(response => {
          TW.workbench.alert.create('Type material was successfully updated.', 'notice')
          commit(MutationNames.NewTypeMaterial)
          return resolve(response)
        })
      }
      else {
        CreateTypeMaterial(type_material).then(response => {
          TW.workbench.alert.create('Type material was successfully created.', 'notice')
          commit(MutationNames.AddTypeMaterial, response)
          commit(MutationNames.NewTypeMaterial, response)
          return resolve(response)
        })
      }
    }
    else {
      resolve()
    }
  })
}