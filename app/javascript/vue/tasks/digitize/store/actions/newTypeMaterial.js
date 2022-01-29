import makeTypeMaterial from 'factory/TypeMaterial.js'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  commit(MutationNames.SetTypeMaterial, makeTypeMaterial())
}
