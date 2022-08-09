import { Otu } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  return new Promise((resolve, reject) => {
    Otu.coordinate(id).then(response => {
      commit(MutationNames.SetCurrentOtu, response.body.find(otu => Number(otu.id) === Number(id)))
      commit(MutationNames.SetOtus, response.body)
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
