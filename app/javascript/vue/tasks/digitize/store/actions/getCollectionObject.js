import { GetCollectionObject } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
    GetCollectionObject(id).then(response => {
      commit(MutationNames.SetCollectionObject, response.body)
      resolve(response.body)
    })
  })
}