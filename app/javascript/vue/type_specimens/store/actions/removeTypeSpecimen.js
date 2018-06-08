import ActionNames from '../actions/actionNames'
import { MutationNames } from '../mutations/mutations'
import { DestroyTypeMaterial } from '../../request/resources'

export default function ({ dispatch, commit, state }, id) {
  commit(MutationNames.SetSaving, true)
  DestroyTypeMaterial(id).then(response => {
    TW.workbench.alert.create('Type specimen was successfully deleted.', 'notice')
    commit(MutationNames.RemoveTypeMaterial, id)
    commit(MutationNames.SetSaving, false)
    if (id == state.type_material.id) {
      dispatch(ActionNames.SetNewTypeMaterial)
    }
  })
};
