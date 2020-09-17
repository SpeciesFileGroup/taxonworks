import { MutationNames } from '../mutations/mutations'
import { CreateContainerItem, UpdateIdentifier } from '../../request/resources'
import Vue from 'vue'

export default function ({ commit, state, dispatch }, coObject) {
  return new Promise((resolve, reject) => {
    if(state.container && !state.containerItems.find(item => {
      return (item.contained_object_id == state.collection_object.id)
    })) {
      let item = { 
        container_id: state.container.id,
        global_entity: state.collection_object.global_id
      }
      CreateContainerItem(item).then(response => {
        commit(MutationNames.AddContainerItem, response.body)
        if(state.containerItems.length === 1 && state.identifiers.length) {
          let identifier = {
            id: state.identifiers[0].id,
            identifier_object_type: 'Container',
            identifier_object_id: state.container.id
          }
          UpdateIdentifier(identifier).then(response => {
            Vue.set(state.identifiers, 0, response.body)
          })
        }
        return resolve(response.body)
      })
    }
  })
}