import { MutationNames } from '../mutations/mutations'
import { UpdateTypeMaterial, UpdateCollectionObject } from '../../request/resources'

export default function ({ commit, state }, data) {
  commit(MutationNames.SetSaving, true)
  delete data.type_material.collection_object_attributes
  UpdateTypeMaterial(data.type_material.id, data).then(response => {
    commit(MutationNames.AddTypeMaterial, response.body)
    commit(MutationNames.SetTypeMaterial, response.body)

    UpdateCollectionObject(state.type_material.collection_object_attributes.id, data.type_material.collection_object_attributes).then(response => {
      commit(MutationNames.SetCollectionObject, response.body)
      LoadSoftvalidation(state.type_material.global_id).then(response => {
        let validation = response.body.validations.soft_validations
        LoadSoftvalidation(state.type_material.collection_object_attributes.global_id).then(response => {
          commit(MutationNames.SetSoftValidation, validation.concat(response.body.validations.soft_validations))
        })
      })
      TW.workbench.alert.create('Type specimen was successfully updated.', 'notice')
      commit(MutationNames.SetSaving, false)
    })
  })
};
