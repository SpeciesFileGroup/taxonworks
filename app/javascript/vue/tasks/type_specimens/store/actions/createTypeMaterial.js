import { MutationNames } from '../mutations/mutations'
import ActionNames from '../actions/actionNames'
import { TypeMaterial } from 'routes/endpoints'
import extend from '../../const/extendRequest.js'

export default ({ dispatch, commit, state }) =>
  new Promise((resolve, reject) => {
    const { type_material } = state

    commit(MutationNames.SetSaving, true)

    TypeMaterial.create({ type_material, extend }).then(response => {
      TW.workbench.alert.create('Type specimen was successfully created.', 'notice')
      commit(MutationNames.AddTypeMaterial, response.body)
      commit(MutationNames.SetTypeMaterial, response.body)
      commit(MutationNames.SetSaving, false)
      dispatch(ActionNames.LoadSoftValidations)
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
