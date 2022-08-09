import { MutationNames } from '../mutations/mutations'
import { Identifier } from 'routes/endpoints'
import {
  COLLECTION_OBJECT,
  CONTAINER
} from 'constants/index.js'

export default ({ commit, state }, id) =>
  new Promise((resolve, reject) => {
    const identifier = state.identifier
    const index = state.collection_objects.findIndex(item => item.id === id)

    identifier.identifier_object_type = state.container
      ? CONTAINER
      : COLLECTION_OBJECT

    if (id && identifier.namespace_id && identifier.identifier && state.settings.saveIdentifier) {
      commit(MutationNames.SetIdentifierObjectId, state.container ? state.container.id : id)
      if (identifier.id) {
        Identifier.update(identifier.id, { identifier }).then(response => {
          commit(MutationNames.SetIdentifier, response.body)
          const identifierIndex = state.identifiers.findIndex(item => item.id === response.body.id)
          state.identifiers[identifierIndex] = response.body
          return resolve(response.body)
        }, (response) => {
          reject(response.body)
        })
      } else {
        if (!state.identifiers.length) {
          Identifier.create({ identifier }).then(response => {
            if (state.settings.increment) {
              response.body.identifier = state.identifier.identifier
            }
            commit(MutationNames.SetIdentifier, response.body)

            if (state.collection_object.id === id) {
              state.collection_object.object_tag = state.identifier.identifier_object.object_tag
            } else {
              state.collection_objects[index].object_tag = state.identifier.identifier_object.object_tag
            }

            state.identifiers.push(response.body)
            return resolve(response.body)
          }, (response) => {
            reject(response.body)
          })
        } else {
          return resolve()
        }
      }
    } else {
      resolve()
    }
  })
