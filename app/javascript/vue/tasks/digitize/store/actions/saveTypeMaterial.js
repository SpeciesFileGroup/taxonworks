import { MutationNames } from '../mutations/mutations'
import { TypeMaterial } from 'routes/endpoints'
import ValidateTypeMaterial from '../../validations/typeMaterial'

export default ({ commit, state: { type_material, collection_object } }) =>
  new Promise((resolve, reject) => {
    commit(MutationNames.SetTypeMaterialBiologicalObjectId, collection_object.id)

    if (ValidateTypeMaterial(type_material)) {
      const saveTypeMaterial = type_material.id
        ? TypeMaterial.update(type_material.id, { type_material })
        : TypeMaterial.create({ type_material })

      saveTypeMaterial.then(response => {
        commit(MutationNames.AddTypeMaterial, response.body)
        commit(MutationNames.NewTypeMaterial)
        return resolve(response.body)
      })
    } else {
      resolve()
    }
  })
