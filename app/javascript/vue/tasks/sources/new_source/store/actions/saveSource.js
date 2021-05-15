import { MutationNames } from '../mutations/mutations'
import { Source, SoftValidation } from 'routes/endpoints'
import { SmartSelectorRefresh } from 'helpers/smartSelector'

import setParam from 'helpers/setParam'

export default ({ state, commit }) => {
  state.settings.saving = true

  const saveSource = state.source.id
    ? Source.update(state.source.id, { source: state.source })
    : Source.create({ source: state.source })

  saveSource.then(response => {
    setSource(response.body)
    SmartSelectorRefresh()
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
    SoftValidation.find(source.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, { sources: { list: [response.body], title: 'Source' } })
    })
    state.settings.saving = false
    commit(MutationNames.SetLastSave, Date.now() + 100)
  }
}
