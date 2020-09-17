import { GetCollectingEvents, GetGeoreferences } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otusId) => {
  GetCollectingEvents(otusId).then(response => {
    const CEs = response.body

    commit(MutationNames.SetCollectingEvents, CEs)
    if (CEs.length) {
      GetGeoreferences(CEs.map(ce => ce.id)).then(response => {
        commit(MutationNames.SetGeoreferences, response.body)
      })
    }
  })
}
