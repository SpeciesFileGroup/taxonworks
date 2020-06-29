import { MutationNames } from '../mutations/mutations'
import { CreateContainer } from '../../request/resources'
import Containers from '../../helpers/ContainersType'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let item = {
      type: Containers.Virtual
    }
    CreateContainer(item).then(response => {
      commit(MutationNames.SetContainer, response.body)
      return resolve(response.body)
    })
  })
}