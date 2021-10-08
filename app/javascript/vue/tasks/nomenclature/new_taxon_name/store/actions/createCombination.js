import { Combination } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, combination) => new Promise((resolve, reject) => {
  const saveRequest = combination.id
    ? Combination.update(combination.id, { combination })
    : Combination.create({ combination, extend: ['protonyms'] })

  saveRequest.then(({ body }) => {
    commit(MutationNames.AddCombination, body)
    TW.workbench.alert.create('Combination was successfully saved.', 'notice')
    resolve(body)
  }).catch(error =>
    reject(error)
  )
})
