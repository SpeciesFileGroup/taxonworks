import { TypeMaterial } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeTypeSpecimen from '../../helpers/makeTypeSpecimen'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    TypeMaterial.where({ collection_object_id: id, extend: ['roles', 'origin_citation'] }).then(({ body }) => {
      const typeMaterials = body.map(item => makeTypeSpecimen(item))

      commit(MutationNames.SetTypeMaterials, typeMaterials)
      resolve(typeMaterials)
    }, error => {
      reject(error)
    })
  })
