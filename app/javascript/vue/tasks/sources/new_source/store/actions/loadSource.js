import { MutationNames } from '../mutations/mutations'
import { GetSourceDocumentations } from '../../request/resources'
import { Source, SoftValidation } from 'routes/endpoints'

import setParam from 'helpers/setParam'

export default ({ state, commit }, id) => {
  Source.find(id).then(response => {
    const source = response.body
    const authors = source.author_roles
    const editors = source.editor_roles
    const people = [].concat(authors, editors).filter(item => item)

    source.roles_attributes = people
    commit(MutationNames.SetSource, source)

    SoftValidation.find(response.body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, { sources: { list: [response.body], title: 'Source' } })
    })

    GetSourceDocumentations(id).then(response => {
      commit(MutationNames.SetDocumentation, response.body)
    })

    setParam('/tasks/sources/new_source', 'source_id', response.body.id)
    state.settings.lastSave = 0
    state.settings.lastEdit = 0
  }, () => {
    TW.workbench.alert.create('No source was found with that ID.', 'alert')
    history.pushState(null, null, '/tasks/sources/new_source')
  })
}
