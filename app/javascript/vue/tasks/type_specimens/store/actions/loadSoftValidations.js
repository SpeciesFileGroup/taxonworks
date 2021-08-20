import { SoftValidation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state }) => {
  const requests = [
    SoftValidation.find(state.type_material.global_id),
    SoftValidation.find(state.type_material.collection_object.global_id)
  ]

  Promise.all(requests).then(responses => {
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

    commit(MutationNames.SetSoftValidation, validations)
  })
}
