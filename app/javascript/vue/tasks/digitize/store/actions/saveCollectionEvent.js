import { MutationNames } from '../mutations/mutations'
import { CollectingEvent } from 'routes/endpoints'
import newCollectingEvent from '../../const/collectingEvent'
import identifierCE from '../../const/identifierCE'

export default ({ commit, state: { collection_event, collectingEventIdentifier } }) =>
  new Promise((resolve, reject) => {
    const identifier = collectingEventIdentifier

    commit(MutationNames.SetCollectionEventIdentifier, identifierCE())
    if (identifier.namespace_id && identifier.identifier) {
      collection_event.identifiers_attributes = [identifier]
    }
    if (JSON.stringify(newCollectingEvent()) === JSON.stringify(collection_event)) {
      return resolve(true)
    } else {
      if (collection_event.units === 'ft') {
        ['minimum_elevation', 'maximum_elevation', 'elevation_precision'].forEach(key => {
          const elevationValue = Number(collection_event[key])
          collection_event[key] = elevationValue > 0 ? elevationValue / 3.281 : undefined
        })
      }
      const savePromise = collection_event.id
        ? CollectingEvent.update(collection_event.id, { collecting_event: collection_event })
        : CollectingEvent.create({ collecting_event: collection_event })

      savePromise.then(response => {
        commit(MutationNames.SetCollectionEvent, response.body)
        if (collection_event?.identifiers?.length) {
          collectingEventIdentifier = collection_event.identifiers[0]
        }
        return resolve(response.body)
      }, (response) => {
        reject(response.body)
      })
    }
  })
