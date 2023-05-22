import { Otu } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state }, id) => {
  return new Promise((resolve, reject) => {
    Otu.distribution(id)
      .then((response) => {
        commit(MutationNames.SetGeoreferences, response.body)
      })
      .finally((_) => {
        state.loadState.distribution = false
      })
    Otu.coordinate(id).then(
      (response) => {
        commit(
          MutationNames.SetCurrentOtu,
          response.body.find((otu) => Number(otu.id) === Number(id))
        )
        commit(MutationNames.SetOtus, response.body)
        resolve(response)
      },
      (error) => {
        reject(error)
      }
    )
  })
}
