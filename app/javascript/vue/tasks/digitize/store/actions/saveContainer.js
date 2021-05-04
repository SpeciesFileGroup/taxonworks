import { MutationNames } from '../mutations/mutations'
import { Container } from 'routes/endpoints'
import Containers from '../../helpers/ContainersType'

export default ({ commit }) =>
  new Promise((resolve, reject) => {
    const container = {
      type: Containers.Virtual
    }
    Container.create({ container }).then(response => {
      commit(MutationNames.SetContainer, response.body)
      return resolve(response.body)
    })
  })
