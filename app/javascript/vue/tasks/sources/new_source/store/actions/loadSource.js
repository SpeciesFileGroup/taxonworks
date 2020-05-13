import { MutationNames } from '../mutations/mutations'
import { GetSource, LoadSoftValidation } from '../../request/resources'

import setParam from 'helpers/setParam'

export default ({ state, commit }, id) => {
  GetSource(id).then(response => {
    commit(MutationNames.SetSource, response.body)
    let authors = state.source.author_roles
    let editors = state.source.editor_roles
    let people = authors.concat(editors)

    commit(MutationNames.SetRoles, people)

    LoadSoftValidation(response.body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body.validations.soft_validations)
    })

    setParam('/tasks/sources/new_source', 'source_id', response.body.id)
    state.settings.lastSave = Date.now()
  }, () => {
    TW.workbench.alert.create('No source was found with that ID.', 'alert')
    history.pushState(null, null, `/tasks/sources/new_source`)
  })
}