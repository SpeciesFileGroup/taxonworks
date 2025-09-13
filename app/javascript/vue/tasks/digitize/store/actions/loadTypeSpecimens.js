import { TypeMaterial } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeTypeMaterial from '@/factory/TypeMaterial.js'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    TypeMaterial.where({
      collection_object_id: id,
      extend: ['roles', 'origin_citation']
    }).then(
      ({ body }) => {
        const typeMaterials = body.map((item) => makeTypeMaterial(item))

        commit(MutationNames.SetTypeMaterials, typeMaterials)
        resolve(typeMaterials)
      },
      (error) => {
        reject(error)
      }
    )
  })
