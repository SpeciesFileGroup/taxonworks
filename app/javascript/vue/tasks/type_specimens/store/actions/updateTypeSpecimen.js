import { MutationNames } from '../mutations/mutations'
import ActionNames from '../actions/actionNames'
import { TypeMaterial, SoftValidation } from 'routes/endpoints'

export default function ({ dispatch, commit }, data) {
  commit(MutationNames.SetSaving, true)
  data.type_material.collection_object_attributes = data.type_material.collection_object
  delete data.type_material.collection_object
  TypeMaterial.update(data.type_material.id, data).then(response => {
    TW.workbench.alert.create('Type specimen was successfully updated.', 'notice')
    commit(MutationNames.AddTypeMaterial, response.body)
    commit(MutationNames.SetTypeMaterial, response.body)
    dispatch(ActionNames.SaveIdentifier)
    SoftValidation.find(data.type_material.global_id).then(response => {
      const validation = response.body.soft_validations
      SoftValidation.find(data.type_material.collection_object_attributes.global_id).then(response => {
        commit(MutationNames.SetSoftValidation, validation.concat(response.body.soft_validations))
      })
    })
    commit(MutationNames.SetSaving, false)
  })
};
