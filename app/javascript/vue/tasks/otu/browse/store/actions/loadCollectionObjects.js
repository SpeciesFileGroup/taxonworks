import { GetOtusCollectionObjects } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) => {
  return new Promise((resolve, reject) => {
    GetOtusCollectionObjects([otuId]).then(response => {
      state.loadState.collectionObjects = false
      commit(MutationNames.SetCollectionObjects, state.collectionObjects.concat(response.body))
      resolve(response)
    }, (error) => {
      reject(error)
    })
  })
}
