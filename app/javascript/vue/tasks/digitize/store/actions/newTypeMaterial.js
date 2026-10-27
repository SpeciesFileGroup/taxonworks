import makeTypeMaterial from '../../helpers/makeTypeMaterial.js'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  commit(MutationNames.SetTypeMaterial, makeTypeMaterial())
}
