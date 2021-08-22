import newTypeMaterial from '../../const/typeMaterial'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  commit(MutationNames.SetTypeMaterial, newTypeMaterial())
}