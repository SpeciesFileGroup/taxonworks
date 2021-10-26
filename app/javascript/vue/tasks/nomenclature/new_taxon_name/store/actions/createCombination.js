import { Combination } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, combination) => new Promise((resolve, reject) => {
  const saveRequest = combination.id
    ? Combination.update(combination.id, { combination, extend: ['protonyms', 'origin_citation'] })
    : Combination.create({ combination, extend: ['protonyms', 'origin_citation'] })

  saveRequest.then(({ body }) => {
    commit(MutationNames.AddCombination, body)
    TW.workbench.alert.create('Combination was successfully saved.', 'notice')
    resolve(body)
  }).catch(error =>
    reject(error)
  )
})
