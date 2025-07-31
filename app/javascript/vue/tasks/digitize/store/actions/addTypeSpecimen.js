import ActionNames from './actionNames'
import makeTypeMaterial from '@/factory/TypeMaterial.js'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit, dispatch }) => {
  const { typeMaterial } = state

  commit(MutationNames.AddTypeMaterial, {
    ...typeMaterial,
    isUnsaved: true
  })

  state.typeMaterial = makeTypeMaterial()

  dispatch(ActionNames.UpdateLastChange)
}
