import { ActionNames } from './actions'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, dispatch }, type_material) => {
  type_material.collection_object_attributes = type_material.collection_object
  commit(MutationNames.SetTypeMaterial, type_material)
  dispatch(ActionNames.LoadSoftValidations)
}
