import { GetCollectingEvents, GetGeoreferences } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) => {
  GetCollectingEvents([otuId]).then(response => {
    const CEs = response.body
    const georeferences = []
    const promises = []

    commit(MutationNames.SetCollectingEvents, CEs)
    CEs.forEach(ce => {
      promises.push(GetGeoreferences(ce.id).then(response => { georeferences.push(response.body) }))
    })

    Promise.all(promises).then(() => {
      commit(MutationNames.SetGeoreferences, ...georeferences)
    })
  })
}
