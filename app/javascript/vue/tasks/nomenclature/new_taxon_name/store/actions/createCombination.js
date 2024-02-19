import { Combination } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default async ({ commit }, combination) => {
  const saveRequest = combination.id
    ? Combination.update(combination.id, {
        combination,
        extend: ['protonyms', 'origin_citation', 'roles']
      })
    : Combination.create({
        combination,
        extend: ['protonyms', 'origin_citation']
      })

  saveRequest
    .then(({ body }) => {
      commit(MutationNames.AddCombination, body)
      TW.workbench.alert.create('Combination was successfully saved.', 'notice')
    })
    .catch(() => {})

  return saveRequest
}
