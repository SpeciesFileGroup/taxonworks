import { MutationNames } from '../mutations/mutations'
import ActionNames from '../actions/actionNames'
import { TypeMaterial } from 'routes/endpoints'
import extend from '../../const/extendRequest.js'

export default ({ dispatch, commit }, type_material) => {
  commit(MutationNames.SetSaving, true)

  TypeMaterial.update(type_material.id, { type_material, extend }).then(response => {
    TW.workbench.alert.create('Type specimen was successfully updated.', 'notice')
    commit(MutationNames.AddTypeMaterial, response.body)
    commit(MutationNames.SetTypeMaterial, response.body)
    dispatch(ActionNames.SaveIdentifier)
    dispatch(ActionNames.LoadSoftValidations)
    commit(MutationNames.SetSaving, false)
  })
};
