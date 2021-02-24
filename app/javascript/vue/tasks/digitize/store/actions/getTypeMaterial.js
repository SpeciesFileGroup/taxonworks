import { GetTypeMaterialCO } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
    GetTypeMaterialCO(id).then(response => {
      response.body.forEach((item, index) => {
        response.body[index].roles_attributes = response.body[index].hasOwnProperty('roles') ? response.body[index].roles : []
      })
      commit(MutationNames.SetTypeMaterials, response.body)
      resolve(response.body)
    }, error => {
      reject(error)
    })
  })
}