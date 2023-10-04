import ActionNames from './actionNames'
import makeTypeSpecimen from '../../helpers/makeTypeSpecimen'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit, dispatch }) => {
  const { typeMaterial } = state

  commit(MutationNames.AddTypeMaterial, {
    ...typeMaterial,
    isUnsaved: true
  })

  state.typeMaterial = makeTypeSpecimen()

  dispatch(ActionNames.UpdateLastChange)
}
