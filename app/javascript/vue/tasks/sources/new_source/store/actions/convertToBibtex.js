import { MutationNames } from '../mutations/mutations'
import { Source, SoftValidation } from 'routes/endpoints'

import setParam from 'helpers/setParam'

export default ({ state, commit }) => {
  state.settings.isConverting = true
  if (state.source.id) {
    Source.update(state.source.id, { convert_to_bibtex: true }).then(response => {
      if (response.body.type === 'Source::Bibtex') {
        setSource(response.body)
        TW.workbench.alert.create('Source was successfully converted.', 'notice')
      } else {
        TW.workbench.alert.create('Source needs to be converted manually', 'error')
      }
      state.settings.isConverting = false
    }, () => {
      state.settings.isConverting = false
    })
  }

  function setSource (source) {
    const authors = source.author_roles
    const editors = source.editor_roles
    const people = [].concat(authors, editors)
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