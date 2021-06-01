import { MutationNames } from '../mutations/mutations'
import ActionNames from '../actions/actionNames'
import { TypeMaterial, SoftValidation } from 'routes/endpoints'

export default function ({ dispatch, commit, state }) {
  return new Promise((resolve, reject) => {
    const { type_material } = state

    commit(MutationNames.SetSaving, true)
    if (state.settings.materialTab !== 'existing') {
      type_material.collection_object_id = undefined
      type_material.collection_object_attributes = state.type_material.collection_object_attributes
    }
    TypeMaterial.create({ type_material: type_material }).then(response => {
      TW.workbench.alert.create('Type specimen was successfully created.', 'notice')
      commit(MutationNames.AddTypeMaterial, response.body)
      commit(MutationNames.SetTypeMaterial, response.body)
      commit(MutationNames.SetSaving, false)
      dispatch(ActionNames.SaveIdentifier)
      SoftValidation.find(response.body.global_id).then(response => {
        const validation = response.body.soft_validations
        SoftValidation.find(state.type_material.collection_object.global_id).then(response => {
          commit(MutationNames.SetSoftValidation, validation.concat(response.body.soft_validations))
        })
      })
      return resolve(response.body)
    }, (response) => {
      return reject(response.body)
    })
  })
}
