import { MutationNames } from '../mutations/mutations'
import { TypeMaterial, CollectionObject, SoftValidation } from 'routes/endpoints'

export default function ({ commit, state }, data) {
  commit(MutationNames.SetSaving, true)
  delete data.type_material.collection_object_attributes
  TypeMaterial.update(data.type_material.id, data).then(response => {
    commit(MutationNames.AddTypeMaterial, response.body)
    commit(MutationNames.SetTypeMaterial, response.body)

    CollectionObject.update(state.type_material.collection_object_attributes.id,
      { collection_object: data.type_material.collection_object_attributes }).then(response => {
      commit(MutationNames.SetCollectionObject, response.body)
      SoftValidation.find(state.type_material.global_id).then(response => {
        const validation = response.body.soft_validations
        SoftValidation.find(state.type_material.collection_object_attributes.global_id).then(response => {
          commit(MutationNames.SetSoftValidation, validation.concat(response.body.soft_validations))
        })
      })
      TW.workbench.alert.create('Type specimen was successfully updated.', 'notice')
      commit(MutationNames.SetSaving, false)
    })
  })
}
