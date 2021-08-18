import { ActionNames } from './actions'
import { MutationNames } from '../mutations/mutations'
import { TypeMaterial } from 'routes/endpoints'

export default ({ state, commit, dispatch }, collectionObject) => {
  const type_material = {
    ...state.type_material,
    collection_object_id: collectionObject.id,
    collection_object_attributes: undefined
  }

  const saveRequest = type_material.id
    ? TypeMaterial.update(state.type_material.id, { type_material })
    : TypeMaterial.create({ type_material })

  saveRequest.then(({ body }) => {
    dispatch(ActionNames.LoadTypeMaterial, body)
    commit(MutationNames.AddTypeMaterial, body)
  })
}
