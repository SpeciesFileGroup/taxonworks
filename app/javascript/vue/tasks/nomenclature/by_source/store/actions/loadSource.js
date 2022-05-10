import { Source } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, sourceId) => {
  Source.find(sourceId, { extend: ['roles'] }).then(({ body }) => {
    history.pushState(null, null, `/tasks/nomenclature/by_source?source_id=${body.id}`)
    commit(MutationNames.SetSource, body)
  })
}