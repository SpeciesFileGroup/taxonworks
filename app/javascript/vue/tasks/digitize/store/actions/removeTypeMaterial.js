import { MutationNames } from '../mutations/mutations'
import { TypeMaterial } from 'routes/endpoints'

export default ({ commit, state }, typeMaterial) =>
  new Promise((resolve, reject) => {
    if (typeMaterial.id) {
      TypeMaterial.destroy(typeMaterial.id).then(response => {
        commit(MutationNames.RemoveTypeMaterial, typeMaterial.id)
        resolve(response.body)
      })
    }
  })
