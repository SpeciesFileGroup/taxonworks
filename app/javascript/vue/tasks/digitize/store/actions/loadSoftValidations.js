import { MutationNames } from '../mutations/mutations'
import { SoftValidation } from 'routes/endpoints'

export default ({ commit, state }) => {
  const promises = []
  const {
    collection_object,
    collection_event,
    taxon_determinations,
    materialTypes,
    biologicalAssociations
  } = state

  promises.push(SoftValidation.find(collection_object.global_id))

  if (collection_event.global_id) {
    promises.push(SoftValidation.find(collection_event.global_id))
  }

  taxon_determinations.forEach(determination => {
    promises.push(SoftValidation.find(determination.global_id))
  })

  materialTypes.forEach(typeMaterial => {
    promises.push(SoftValidation.find(typeMaterial.global_id))
  })

  biologicalAssociations.forEach(biologicalAssociation => {
    promises.push(SoftValidation.find(biologicalAssociation.global_id))
  })

  Promise.all(promises).then(responses => {
    const validations = {}
    const list = responses.filter(({ body }) => body.soft_validations.length)

    list.forEach(({ body }) => {
      const objectType = body.instance.klass

      if (validations[objectType]) {
        validations[objectType].list.concat(body)
      } else {
        validations[objectType] = { list: [body], title: objectType }
      }
    })

    commit(MutationNames.SetSoftValidations, validations)
  })
}
