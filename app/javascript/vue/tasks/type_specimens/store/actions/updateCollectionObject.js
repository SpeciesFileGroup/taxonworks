import { ActionNames } from './actions'
import { MutationNames } from '../mutations/mutations'
import { TypeMaterial, CollectionObject } from 'routes/endpoints'

export default ({ commit, state, dispatch }, data) => {
  commit(MutationNames.SetSaving, true)

  TypeMaterial.update(data.type_material.id, data).then(response => {
    commit(MutationNames.AddTypeMaterial, response.body)
    commit(MutationNames.SetTypeMaterial, response.body)

    CollectionObject.update(state.type_material.collection_object_attributes.id,
      { collection_object: data.type_material.collection_object_attributes }).then(response => {
      commit(MutationNames.SetCollectionObject, response.body)
      dispatch(ActionNames.LoadSoftValidations)
      TW.workbench.alert.create('Type specimen was successfully updated.', 'notice')
      commit(MutationNames.SetSaving, false)
    })
  })
}
