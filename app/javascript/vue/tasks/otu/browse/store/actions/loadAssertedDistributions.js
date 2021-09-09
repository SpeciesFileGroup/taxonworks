import { AssertedDistribution } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otusId) => new Promise((resolve, reject) => {
  AssertedDistribution.where({ otu_id: otusId, geo_json: true }).then(response => {
    const assertedDistributions = response.body.sort((a, b) => {
      const compareA = a.geographic_area.name
      const compareB = b.geographic_area.name
      if (compareA < compareB) {
        return -1
      } else if (compareA > compareB) {
        return 1
      } else {
        return 0
      }
    })

    commit(MutationNames.SetAssertedDistributions, assertedDistributions)
    resolve(response)
  }, error => {
    reject(error)
  })
})
