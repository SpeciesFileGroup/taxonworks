import { MutationNames } from '../mutations/mutations'
import { GetSource } from '../../request/resources'

import setParam from 'helpers/setParam'

export default ({ state, commit }, id) => {
  GetSource(id).then(response => {
    commit(MutationNames.SetSource, response.body)
    let authors = state.source.author_roles
    let editors = state.source.editor_roles
    let people = authors.concat(editors)

    commit(MutationNames.SetRoles, people)
    setParam('/tasks/sources/new_source/index', 'source_id', response.body.id)
  })
}