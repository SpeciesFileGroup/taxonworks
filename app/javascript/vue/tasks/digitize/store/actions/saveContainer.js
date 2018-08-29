import { MutationNames } from '../mutations/mutations'
import { CreateContainer } from '../../request/resources'

export default function ({ commit, state }) {
  let type = state.COTypes.find((item) => { return item.id == state.collection_object.preparation_type_id })
  return new Promise((resolve, reject) => {
    let item = { 
      type: 'Container::' + type.name.toPascalCase()
    }
    CreateContainer(item).then(response => {
      TW.workbench.alert.create('Container was successfully created.', 'notice')
      commit(MutationNames.SetContainer, response)
      return resolve(response)
    })
  })
}