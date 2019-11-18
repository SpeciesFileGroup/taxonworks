import { CloneSource } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import setParam from 'helpers/setParam'

export default ({ state, commit }) => {
  CloneSource(state.source.id).then(response => {
    commit(MutationNames.SetSource, response.body)
    setParam('/tasks/sources/new_source', 'source_id', response.body.id)
    TW.workbench.alert.create('Source was successfully cloned.', 'notice')
  })
}