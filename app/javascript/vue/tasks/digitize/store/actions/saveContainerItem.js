import { MutationNames } from '../mutations/mutations'
import { CreateContainerItem } from '../../request/resources'

export default function ({ commit, state }, coObject) {
  return new Promise((resolve, reject) => {
    if(state.container && !state.containerItems.find(item => {
      return (item.contained_object_id == state.collection_object.id)
    })) {
      let item = { 
        container_id: state.container.id, 
        global_entity: state.collection_object.global_id
      }
      CreateContainerItem(item).then(response => {
        TW.workbench.alert.create('Container item was successfully created.', 'notice')
        commit(MutationNames.AddContainerItem, response)
        return resolve(response)
      })
    }
  })
}