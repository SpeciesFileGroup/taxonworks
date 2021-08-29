import { MutationNames } from '../mutations/mutations'
import { CollectingEvent, Identifier } from 'routes/endpoints'
import newCollectingEvent from 'factory/CollectingEvent.js'
import makeIdentifier from 'factory/Identifier'
import {
  COLLECTING_EVENT,
  IDENTIFIER_LOCAL_TRIP_CODE
} from 'constants/index.js'

export default ({ commit, state: { collecting_event, collectingEventIdentifier } }) =>
  new Promise((resolve, reject) => {
    if (JSON.stringify(newCollectingEvent()) === JSON.stringify(collecting_event)) {
      return resolve(true)
    }

    const identifier = collectingEventIdentifier

    if (!identifier.id) {
      if (identifier.namespace_id && identifier.identifier) {
        collecting_event.identifiers_attributes = [identifier]
      }
    } else {
      Identifier.update(identifier.id, { identifier }).then(({ body }) => {
        commit(MutationNames.SetCollectingEventIdentifier, body)
      })
    }

    if (collecting_event.units === 'ft') {
      ['minimum_elevation', 'maximum_elevation', 'elevation_precision'].forEach(key => {
        const elevationValue = Number(collecting_event[key])
        collecting_event[key] = elevationValue > 0 ? elevationValue / 3.281 : undefined
      })
    }

    const saveCE = collecting_event.id
      ? CollectingEvent.update(collecting_event.id, { collecting_event })
      : CollectingEvent.create({ collecting_event })

    saveCE.then(({ body }) => {
      commit(MutationNames.SetCollectingEvent, body)

      if (!identifier.id) {
        commit(MutationNames.SetCollectingEventIdentifier, body.identifiers[0] || makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT))
      }

      return resolve(body)
    }, error => {
      reject(error)
    })
  })
