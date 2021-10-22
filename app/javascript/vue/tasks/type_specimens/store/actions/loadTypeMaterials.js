import { MutationNames } from '../mutations/mutations'
import { TypeMaterial } from 'routes/endpoints'
import extend from '../../const/extendRequest.js'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    TypeMaterial.where({ protonym_id: id, extend }).then(response => {
      commit(MutationNames.SetTypeMaterials, response.body)
      resolve(response.body)
    }, (error) => {
      reject(error)
    }).finally(() => {
      commit(MutationNames.SetLoading, false)
    })
  })
