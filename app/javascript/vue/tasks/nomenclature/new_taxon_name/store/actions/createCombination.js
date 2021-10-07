import { Combination } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, combination) => new Promise((resolve, reject) => {
  const saveRequest = combination.id
    ? Combination.update(combination.id, { combination })
    : Combination.create({ combination })

  saveRequest.then(({ body }) => {
    commit(MutationNames.AddCombination, body)
    resolve(body)
  }).catch(error =>
    reject(error)
  )
})
