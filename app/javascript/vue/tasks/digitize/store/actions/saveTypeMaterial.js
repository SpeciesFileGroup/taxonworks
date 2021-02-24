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
          commit(MutationNames.NewTypeMaterial)
          return resolve(response.body)
        })
      }
      else {
        CreateTypeMaterial(type_material).then(response => {
          commit(MutationNames.AddTypeMaterial, response.body)
          commit(MutationNames.NewTypeMaterial, response.body)
          return resolve(response.body)
        })
      }
    }
    else {
      resolve()
    }
  })
}