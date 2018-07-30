import { MutationNames } from '../mutations/mutations'
import { UpdateTypeMaterial, CreateTypeMaterial } from '../../request/resources'

function validate(typeMaterial) {
  return (typeMaterial.protonym_id && typeMaterial.biological_object_id && typeMaterial.type_type)
}

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let type_material = state.type_material
    type_material.collection_object = state.collection_object
    if(validate(type_material)) {
      if(type_material.id) {
        UpdateTypeMaterial(type_material).then(response => {
          TW.workbench.alert.create('Taxon determination was successfully updated.', 'notice')
          commit(MutationNames.SetTypeMaterial, response)
          return resolve(response)
        })
      }
      else {
        CreateTypeMaterial(type_material).then(response => {
          TW.workbench.alert.create('Taxon determination was successfully created.', 'notice')
          commit(MutationNames.SetTypeMaterial, response)
          return resolve(response)
        })
      }
    }
  })
}