import { GetContainer } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, globalId) {
  return new Promise((resolve, reject) => {
    GetContainer(globalId).then(response => {
      console.log(response)
      // commit(MutationNames.SetCollectionObject, response)
      resolve(response)
    })
  })
}