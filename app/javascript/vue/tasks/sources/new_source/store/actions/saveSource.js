import { MutationNames } from '../mutations/mutations'
import { CreateSource, UpdateSource, LoadSoftValidation } from '../../request/resources'

import setParam from 'helpers/setParam'

export default ({ state, commit }) => {
  state.settings.saving = true
  if(state.source.id) {
    UpdateSource(state.source).then(response => {
      setSource(response.body)
      TW.workbench.alert.create('Source was successfully updated.', 'notice')
    }, () => {
      state.settings.saving = false
    })
  } else {
    CreateSource(state.source).then(response => {
      setSource(response.body)
      TW.workbench.alert.create('Source was successfully created.', 'notice')
    }, () => {
      state.settings.saving = false
    })
  }

  function setSource (source) {
    const authors = source.author_roles
    const editors = source.editor_roles
    const people = [].concat(authors, editors).filter(item => item)
    source.roles_attributes = people

    commit(MutationNames.SetSource, source)
    setParam('/tasks/sources/new_source', 'source_id', source.id)
    LoadSoftValidation(source.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body.validations.soft_validations)
    })
    state.settings.saving = false
    commit(MutationNames.SetLastSave, Date.now() + 100)
  }
}