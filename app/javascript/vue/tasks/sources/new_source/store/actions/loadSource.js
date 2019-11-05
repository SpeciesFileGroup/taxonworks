import { MutationNames } from '../mutations/mutations'
// import newSource from '../../const/source'
import { GetSource } from '../../request/resources'

export default ({ commit }, id) => {
  GetSource(id).then(response => {
    commit(MutationNames.SetSource, response.body)
    setParam('/tasks/sources/new_source/index', 'source_id', response.body.id)
  })
}