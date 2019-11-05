import { MutationNames } from '../mutations/mutations'
import newSource from '../../const/source'

export default ({ state, commit }) => {
  commit(MutationNames.SetSource, newSource())
  history.pushState(null, null, `/tasks/sources/new_source/index`)
}