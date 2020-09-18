import { GetOtuAssertedDistribution } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) => {
  GetOtuAssertedDistribution({ otu_id: otuId, geo_json: true }).then(response => {
    state.loadState.assertedDistribution = false
    commit(MutationNames.SetAssertedDistributions, state.assertedDistributions.concat(response.body).sort((a, b) => {
      const compareA = a.geographic_area.name
      const compareB = b.geographic_area.name
      if (compareA < compareB) {
        return -1
      } else if (compareA > compareB) {
        return 1
      } else {
        return 0
      }
    }))
  })
}
