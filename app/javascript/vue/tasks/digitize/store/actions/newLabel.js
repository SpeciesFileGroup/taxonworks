import newLabel from '../../const/label'
import { MutationNames } from '../mutations/mutations'

export default function({ commit }) {
  commit(MutationNames.SetLabel, newLabel())
}