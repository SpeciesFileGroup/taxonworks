import { MutationNames } from '../mutations/mutations'
import ActionNames from '../actions/actionNames'
import { UpdateTypeMaterial, LoadSoftvalidation } from '../../request/resources'

export default function ({dispatch, commit, state }, data) {
  commit(MutationNames.SetSaving, true)
  data.type_material.collection_object_attributes = data.type_material.collection_object
  delete data.type_material.collection_object
  UpdateTypeMaterial(data.type_material.id, data).then(response => {
    TW.workbench.alert.create('Type specimen was successfully updated.', 'notice')
    commit(MutationNames.AddTypeMaterial, response.body)
    commit(MutationNames.SetTypeMaterial, response.body)
    dispatch(ActionNames.SaveIdentifier)
    LoadSoftvalidation(data.type_material.global_id).then(response => {
      let validation = response.body.validations.soft_validations
      LoadSoftvalidation(data.type_material.collection_object_attributes.global_id).then(response => {
        commit(MutationNames.SetSoftValidation, validation.concat(response.body.validations.soft_validations))
      })
    })
    commit(MutationNames.SetSaving, false)
  })
};
