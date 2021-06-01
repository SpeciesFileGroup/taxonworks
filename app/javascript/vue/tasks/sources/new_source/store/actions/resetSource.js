import { MutationNames } from '../mutations/mutations'
import newSource from '../../const/source'

export default ({ state, commit }) => {
  const source = newSource()
  const locked = state.settings.lock
  state.settings.lastEdit = 0
  state.settings.lastSave = 0

  Object.keys(locked).forEach(key => {
    source[key] = locked[key] ? state.source[key] : undefined
  })
  if (!locked.type) {
    source.type = 'Source::Bibtex'
  }
  commit(MutationNames.SetSoftValidation, undefined)
  commit(MutationNames.SetSource, source)
  history.pushState(null, null, `/tasks/sources/new_source`)
}
