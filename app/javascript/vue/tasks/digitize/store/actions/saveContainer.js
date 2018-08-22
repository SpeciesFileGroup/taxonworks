import { MutationNames } from '../mutations/mutations'
import { CreateContainer } from '../../request/resources'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let item = { 
      type: state.COTypes[state.collection_object.preparation_type_id].toPascalCase()
    }
    CreateContainer(item).then(response => {
      TW.workbench.alert.create('Container was successfully created.', 'notice')
      commit(MutationNames.AddContainerItem, response)
      return resolve(response)
    })
  })
}