import { TypeMaterial } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    TypeMaterial.where({ collection_object_id: id }).then(response => {
      response.body.forEach((item, index) => {
        response.body[index].roles_attributes = response.body[index].roles || []
      })
      commit(MutationNames.SetTypeMaterials, response.body)
      resolve(response.body)
    }, error => {
      reject(error)
    })
  })
