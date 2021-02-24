import { MutationNames } from '../mutations/mutations'
import ActionNames from '../actions/actionNames'
import { CreateTypeMaterial, LoadSoftvalidation } from '../../request/resources'

export default function ({ dispatch, commit, state }) {
  return new Promise((resolve, rejected) => {
    let type_material = state.type_material

    commit(MutationNames.SetSaving, true)
    if (state.settings.materialTab !== 'existing') {
      type_material.collection_object_id = undefined
      type_material.collection_object_attributes = state.type_material.collection_object_attributes
    }
    CreateTypeMaterial({ type_material: type_material }).then(response => {
      TW.workbench.alert.create('Type specimen was successfully created.', 'notice')
      commit(MutationNames.AddTypeMaterial, response.body)
      commit(MutationNames.SetTypeMaterial, response.body)
      commit(MutationNames.SetSaving, false)
      dispatch(ActionNames.SaveIdentifier)
      LoadSoftvalidation(response.body.global_id).then(response => {
        let validation = response.body.validations.soft_validations
        LoadSoftvalidation(state.type_material.collection_object.global_id).then(response => {
          commit(MutationNames.SetSoftValidation, validation.concat(response.body.validations.soft_validations))
        })
      })
      return resolve(response.body)
    })
  }, (response) => {
    return rejected(response.body)
  })
};
