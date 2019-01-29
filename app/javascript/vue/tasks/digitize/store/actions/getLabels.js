import { GetLabelsFromCE } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }, id) {
  return new Promise((resolve, reject) => {
    GetLabelsFromCE(id).then(response => {
      if(response.length)
        commit(MutationNames.SetLabel, response[0])
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}