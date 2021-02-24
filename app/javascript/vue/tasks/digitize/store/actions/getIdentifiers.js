import { GetIdentifiersFromCO } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }, id) {
  return new Promise((resolve, reject) => {
    GetIdentifiersFromCO(id).then(response => {
      commit(MutationNames.SetIdentifiers, response.body)
      resolve(response.body)
    })
  })
}