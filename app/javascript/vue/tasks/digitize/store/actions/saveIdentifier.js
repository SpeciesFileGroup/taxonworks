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
          commit(MutationNames.SetIdentifier, response.body)
          const index = state.identifiers.findIndex(item => {
            return item.id === response.body.id
          })
          Vue.set(state.identifiers, index, response.body)
          return resolve(response.body)
        }, (response) => {
          reject(response.body)
        })
      } else {
        if (!state.identifiers.length) {
          CreateIdentifier(identifier).then(response => {
            if (state.settings.increment) {
              response.body.identifier = state.identifier.identifier
            }
            commit(MutationNames.SetIdentifier, response.body)
            state.collection_object.object_tag = state.identifier.identifier_object.object_tag
            state.identifiers.push(response.body)
            return resolve(response.body)
          }, (response) => {
            reject(response.body)
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