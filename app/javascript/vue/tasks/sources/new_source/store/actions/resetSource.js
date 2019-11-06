import { MutationNames } from '../mutations/mutations'
import newSource from '../../const/source'

export default ({ state, commit }) => {
  let source = newSource()
  let locked = state.settings.lock

  Object.keys(locked).forEach(key => {
    source[key] = locked[key] ? state.source[key] : undefined
  })
  
  commit(MutationNames.SetSource, source)
  history.pushState(null, null, `/tasks/sources/new_source/index`)
}