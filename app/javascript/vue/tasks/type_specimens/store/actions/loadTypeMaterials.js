import { MutationNames } from '../mutations/mutations'
import { TypeMaterial } from 'routes/endpoints'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    TypeMaterial.where({ protonym_id: id }).then(response => {
      commit(MutationNames.SetTypeMaterials, response.body)
      resolve(response.body)
    }, (error) => {
      reject(error)
    }).finally(() => {
      commit(MutationNames.SetLoading, false)
    })
  })
