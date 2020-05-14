import { MutationNames } from '../mutations/mutations'
import { CreateIdentifier, UpdateIdentifier } from '../../request/resources'
import Vue from 'vue'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let identifier = state.identifier

    identifier.identifier_object_type = state.container ? 'Container' : 'CollectionObject'
    if (state.collection_object.id && identifier.namespace_id && identifier.identifier && state.settings.saveIdentifier) {
      commit(MutationNames.SetIdentifierObjectId, state.container ? state.container.id : state.collection_object.id)
      if (identifier.id) {
        UpdateIdentifier(identifier).then(response => {
          commit(MutationNames.SetIdentifier, response)
          const index = state.identifiers.findIndex(item => {
            return item.id === response.id
          })
          Vue.set(state.identifiers, index, response)
          return resolve(response)
        }, (response) => {
          reject(response)
        })
      } else {
        if (!state.identifiers.length) {
          CreateIdentifier(identifier).then(response => {
            if (state.settings.increment) {
              response.identifier = state.identifier.identifier
            }
            commit(MutationNames.SetIdentifier, response)
            state.collection_object.object_tag = state.identifier.identifier_object.object_tag
            state.identifiers.push(response)
            return resolve(response)
          }, (response) => {
            reject(response)
          })
        } else {
          return resolve()
        }
      }
    }
    else {
      resolve()
    }
  })
}