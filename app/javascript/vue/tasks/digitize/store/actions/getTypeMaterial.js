import { GetTypeMaterialCO } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
    GetTypeMaterialCO(id).then(response => {
      response.forEach((item, index) => {
        response[index].roles_attributes = response[index].hasOwnProperty('roles') ? response[index].roles : []
      })
      commit(MutationNames.SetTypeMaterials, response)
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}