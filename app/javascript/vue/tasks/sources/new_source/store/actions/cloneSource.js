import { CloneSource, LoadSoftValidation } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import setParam from 'helpers/setParam'

export default ({ state, commit }) => {
  CloneSource(state.source.id).then(response => {
    const source = response.body

    const authors = source.author_roles
    const editors = source.editor_roles
    const people = [].concat(authors, editors).filter(item => item)
    source.roles_attributes = people

    commit(MutationNames.SetSource, source)

    LoadSoftValidation(response.body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body.validations.soft_validations)
    })

    setParam('/tasks/sources/new_source', 'source_id', response.body.id)
    TW.workbench.alert.create('Source was successfully cloned.', 'notice')
  })
}