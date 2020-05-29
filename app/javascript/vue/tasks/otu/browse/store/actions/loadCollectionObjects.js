import { GetOtusCollectionObjects } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) => {
  return new Promise((resolve, reject) => {
    GetOtusCollectionObjects([otuId]).then(response => {
      commit(MutationNames.SetCollectionObjects, response.body)
      resolve(response)
    }, (error) => {
      reject(error)
    })
  })
}
