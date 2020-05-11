import { GetOtusCollectionObjects } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) => {
  GetOtusCollectionObjects(otuId).then(response => {
    commit(MutationNames.SetCollectionObjects, response.body)
  })
}
