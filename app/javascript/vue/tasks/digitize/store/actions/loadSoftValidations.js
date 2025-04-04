import { MutationNames } from '../mutations/mutations'
import { SoftValidation } from '@/routes/endpoints'
import { useTaxonDeterminationStore } from '../pinia'

export default ({ commit, state }) => {
  const determinationStore = useTaxonDeterminationStore()
  const {
    collection_object,
    collecting_event,
    materialTypes,
    biologicalAssociations,
    georeferences
  } = state

  const objects = [
    collection_object,
    collecting_event,
    ...determinationStore.determinations,
    ...materialTypes,
    ...biologicalAssociations,
    ...georeferences
  ]

  const promises = objects
    .filter((item) => item.global_id)
    .map((item) => SoftValidation.find(item.global_id))

  Promise.all(promises)
    .then((responses) => {
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
    .catch(() => {})
}
