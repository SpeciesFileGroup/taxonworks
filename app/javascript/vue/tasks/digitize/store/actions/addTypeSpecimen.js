import makeTypeSpecimen from '../../helpers/makeTypeSpecimen'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  const { typeMaterial } = state

  commit(MutationNames.AddTypeMaterial, {
    ...typeMaterial,
    isUnsaved: true
  })

  state.typeMaterial = makeTypeSpecimen()
}
