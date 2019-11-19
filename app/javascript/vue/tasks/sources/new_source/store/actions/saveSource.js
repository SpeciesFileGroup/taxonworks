import { MutationNames } from '../mutations/mutations'
import { CreateSource, UpdateSource, LoadSoftValidation } from '../../request/resources'

import setParam from 'helpers/setParam'

export default ({ state, commit }) => {
  if(state.source.id) {
    UpdateSource(state.source).then(response => {
      commit(MutationNames.SetSource, response.body)
      setParam('/tasks/sources/new_source', 'source_id', response.body.id)
      let authors = state.source.author_roles
      let editors = state.source.editor_roles
      let people = authors.concat(editors)
  
      commit(MutationNames.SetRoles, people)
      LoadSoftValidation(response.body.global_id).then(response => {
        commit(MutationNames.SetSoftValidation, response.body.validations.soft_validations)
      })
      TW.workbench.alert.create('Source was successfully updated.', 'notice')
    })
  } else {
    CreateSource(state.source).then(response => {
      commit(MutationNames.SetSource, response.body)
      setParam('/tasks/sources/new_source', 'source_id', response.body.id)
      let authors = state.source.author_roles
      let editors = state.source.editor_roles
      let people = authors.concat(editors)
  
      commit(MutationNames.SetRoles, people)
      LoadSoftValidation(response.body.global_id).then(response => {
        commit(MutationNames.SetSoftValidation, response.body.validations.soft_validations)
      })
      TW.workbench.alert.create('Source was successfully created.', 'notice')
    })
  }
}