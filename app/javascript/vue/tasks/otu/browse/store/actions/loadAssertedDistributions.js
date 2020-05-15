import { GetOtuAssertedDistribution } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) => {
  GetOtuAssertedDistribution({ otu_id: otuId, geo_json: true }).then(response => {
    commit(MutationNames.SetAssertedDistributions, response.body)
  })
}
