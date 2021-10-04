import { Source, SoftValidation } from 'routes/endpoints'
import { MutationNames } from '../../store/mutations/mutations'
import setParam from 'helpers/setParam'

export default ({ state, commit }) => {
  Source.clone(state.source.id, { extend: ['roles'] }).then(response => {
    const source = response.body

    const authors = source.author_roles
    const editors = source.editor_roles
    const people = [].concat(authors, editors).filter(item => item)
    source.roles_attributes = people

    commit(MutationNames.SetSource, source)

    SoftValidation.find(response.body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, { sources: { list: [response.body], title: 'Source' } })
    })

    setParam('/tasks/sources/new_source', 'source_id', response.body.id)
    TW.workbench.alert.create('Source was successfully cloned.', 'notice')
  })
}