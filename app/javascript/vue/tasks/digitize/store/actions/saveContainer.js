import { MutationNames } from '../mutations/mutations'
import { Container } from 'routes/endpoints'
import { CONTAINER_VIRTUAL } from 'constants/index.js'

export default ({ commit }) =>
  new Promise((resolve, reject) => {
    const container = {
      type: CONTAINER_VIRTUAL
    }
    Container.create({ container }).then(response => {
      commit(MutationNames.SetContainer, response.body)
      return resolve(response.body)
    }).then(error => {
      return reject(error)
    })
  })
