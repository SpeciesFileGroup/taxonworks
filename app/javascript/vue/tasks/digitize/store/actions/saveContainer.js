import { MutationNames } from '../mutations/mutations'
import { CreateContainer } from '../../request/resources'
import Containers from '../../helpers/ContainersType'

export default function ({ commit, state }) {
  let type = state.COTypes.find((item) => { return item.id == state.preparation_type_id })
  return new Promise((resolve, reject) => {
    let item = { 
      type: (type ? Containers[type.name.toPascalCase()] : Containers.Virtual)
    }
    CreateContainer(item).then(response => {
      TW.workbench.alert.create('Container was successfully created.', 'notice')
      commit(MutationNames.SetContainer, response)
      return resolve(response)
    })
  })
}