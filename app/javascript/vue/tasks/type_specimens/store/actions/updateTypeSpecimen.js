import { MutationNames } from '../mutations/mutations'
import ActionNames from '../actions/actionNames'
import { TypeMaterial } from 'routes/endpoints'

export default ({ dispatch, commit }, data) => {
  commit(MutationNames.SetSaving, true)

  TypeMaterial.update(data.type_material.id, data).then(response => {
    TW.workbench.alert.create('Type specimen was successfully updated.', 'notice')
    commit(MutationNames.AddTypeMaterial, response.body)
    commit(MutationNames.SetTypeMaterial, response.body)
    dispatch(ActionNames.LoadSoftValidations)
    commit(MutationNames.SetSaving, false)
  })
};
