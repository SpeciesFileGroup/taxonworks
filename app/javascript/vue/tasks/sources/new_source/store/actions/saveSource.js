import { ActionNames } from './actions'
import { MutationNames } from '../mutations/mutations'
import { Source } from 'routes/endpoints'
import { smartSelectorRefresh } from 'helpers/smartSelector'

import setParam from 'helpers/setParam'

export default ({ state, commit, dispatch }) => {
  state.settings.saving = true

  const saveSource = state.source.id
    ? Source.update(state.source.id, { source: state.source, extend: 'roles' })
    : Source.create({ source: state.source, extend: 'roles' })

  saveSource.then(({ body }) => {
    setSource(body)
    dispatch(ActionNames.LoadSoftValidations, body.global_id)
    smartSelectorRefresh()
    TW.workbench.alert.create('Source was successfully saved.', 'notice')
  }).finally(() => {
    state.settings.saving = false
  })

  function setSource (source) {
    const authors = source.author_roles
    const editors = source.editor_roles
    const people = [].concat(authors, editors).filter(item => item)
    source.roles_attributes = people

    commit(MutationNames.SetSource, source)
    setParam('/tasks/sources/new_source', 'source_id', source.id)

    state.settings.saving = false
    commit(MutationNames.SetLastSave, Date.now() + 100)
  }
}
