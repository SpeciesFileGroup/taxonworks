import { MutationNames } from '../mutations/mutations'
import { Identifier } from 'routes/endpoints'

export default ({ commit, state }) =>
  new Promise((resolve, reject) => {
    const identifier = state.identifier

    identifier.identifier_object_type = state.container ? 'Container' : 'CollectionObject'
    if (state.collection_object.id && identifier.namespace_id && identifier.identifier && state.settings.saveIdentifier) {
      commit(MutationNames.SetIdentifierObjectId, state.container ? state.container.id : state.collection_object.id)
      if (identifier.id) {
        Identifier.update(identifier.id, { identifier }).then(response => {
          commit(MutationNames.SetIdentifier, response.body)
          const index = state.identifiers.findIndex(item => item.id === response.body.id)
          state.identifiers[index] = response.body
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
