import makeLabel from 'factory/Label.js'
import { MutationNames } from '../mutations/mutations'
import { COLLECTING_EVENT } from 'constants/index.js'

export default ({ commit }) => {
  commit(MutationNames.SetLabel, makeLabel(COLLECTING_EVENT))
}
