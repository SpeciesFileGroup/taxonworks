import newTypeMaterial from '../../const/typeMaterial'
import { MutationNames } from '../mutations/mutations'

export default function({ commit }) {
  commit(MutationNames.SetTypeMaterial, newTypeMaterial())
}