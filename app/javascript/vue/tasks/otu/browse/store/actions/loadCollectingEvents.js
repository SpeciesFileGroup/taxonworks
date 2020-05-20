import { GetCollectingEvents, GetGeoreferences } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) => {
  GetCollectingEvents([otuId]).then(response => {
    const CEs = response.body
    const georeferences = []
    const promises = []

    commit(MutationNames.SetCollectingEvents, CEs)

    GetGeoreferences(CEs.map(ce => ce.id)).then(response => {
      commit(MutationNames.SetGeoreferences, response.body)
    })
  })
}
