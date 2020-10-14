import { GetOtuAssertedDistribution } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otusId) => {
  return new Promise((resolve, reject) => {
    GetOtuAssertedDistribution({ otu_id: otusId, geo_json: true }).then(response => {
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
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
