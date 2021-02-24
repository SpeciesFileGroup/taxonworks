import { MutationNames } from '../mutations/mutations'
import { CreateCollectionEvent, UpdateCollectionEvent } from '../../request/resources'
import CollectingEvent from '../../const/collectingEvent'
import identifierCE from '../../const/identifierCE'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let collection_event = state.collection_event
    let identifier = state.collectingEventIdentifier
    commit(MutationNames.SetCollectionEventIdentifier, identifierCE())
    if (identifier.namespace_id && identifier.identifier) {
      collection_event.identifiers_attributes = [identifier]
    }
    if (JSON.stringify(CollectingEvent()) == JSON.stringify(collection_event)) {
      return resolve(true)
    } else {
      if (collection_event.units === 'ft') {
        ['minimum_elevation', 'maximum_elevation', 'elevation_precision'].forEach(key => {
          const elevationValue = Number(collection_event[key])
          collection_event[key] = elevationValue > 0 ? elevationValue / 3.281 : undefined
        })
      }
      if (collection_event.id) {
        UpdateCollectionEvent(collection_event).then(response => {
          commit(MutationNames.SetCollectionEvent, response.body)
          if(state.collection_event.hasOwnProperty('identifiers') && state.collection_event.identifiers.length) {
            state.collectingEventIdentifier = state.collection_event.identifiers[0]
          }
          return resolve(response.body)
        }, (response) => {
          reject(response.body)
        })
      }
      else {
        CreateCollectionEvent(collection_event).then(response => {
          commit(MutationNames.SetCollectionEvent, response.body)
          if(state.collection_event.hasOwnProperty('identifiers') && state.collection_event.identifiers.length) {
            state.collectingEventIdentifier = state.collection_event.identifiers[0]
          }
          return resolve(response.body)
        }, (response) => {
          reject(response.body)
        })
      }
    }
  })
}