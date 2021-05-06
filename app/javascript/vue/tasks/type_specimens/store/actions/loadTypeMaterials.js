import { MutationNames } from '../mutations/mutations'
import { TypeMaterial } from 'routes/endpoints'

export default function ({ commit }, id) {
  return new Promise((resolve, reject) => {
    TypeMaterial.where({ protonym_id: id }).then(response => {
      commit(MutationNames.SetTypeMaterials, response.body)
      commit(MutationNames.SetLoading, false)
      return resolve(response.body)
    }, (error) => {
      commit(MutationNames.SetLoading, false)
      return reject(error)
    })
  })
}
