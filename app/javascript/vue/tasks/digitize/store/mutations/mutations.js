import setCollectionEventLabel from './setCollectionEventLabel'
import setCollectionEventCollectors from './setCollectionEventCollectors'
import setCollectionEventDate from './setCollectionEventDate'
import setCollectionEventDatum from './setCollectionEventDatum'
import setCollectionEventElevation from './setCollectionEventElevation'
import setCollectionEventGeolocation from './setCollectionEventGeolocation'
import setCollectionEventHabitat from './setCollectionEventHabitat'
import setCollectionEventLatitude from './setCollectionEventLatitude'
import setCollectionEventLocality from './setCollectionEventLocality'
import setCollectionEventLongitude from './setCollectionEventLongitude'
import setCollectionEventMethod from './setCollectionEventMethod'
import setCollectionEventTripIdentifier from './setCollectionEventTripIdentifier'


const MutationNames = {
  SetCollectionEventLabel: 'setCollectionEventLabel',
  setCollectionEventCollectors: 'setCollectionEventCollectors',
  setCollectionEventDate: 'setCollectionEventDate',
  setCollectionEventDatum: 'setCollectionEventDatum',
  setCollectionEventElevation: 'setCollectionEventElevation',
  setCollectionEventGeolocation: 'setCollectionEventGeolocation',
  setCollectionEventHabitat: 'setCollectionEventHabitat',
  setCollectionEventLatitude: 'setCollectionEventLatitude',
  setCollectionEventLocality: 'setCollectionEventLocality',
  setCollectionEventLongitude: 'setCollectionEventLongitude',
  setCollectionEventMethod: 'setCollectionEventMethod',
  setCollectionEventTripIdentifier: 'setCollectionEventTripIdentifier',
}

const MutationFunctions = {
  [MutationNames.SetCollectionEventLabel]: setCollectionEventLabel,
  [MutationNames.setCollectionEventCollectors]: setCollectionEventCollectors,
  [MutationNames.setCollectionEventDate]: setCollectionEventDate,
  [MutationNames.setCollectionEventDatum]: setCollectionEventDatum,
  [MutationNames.setCollectionEventElevation]: setCollectionEventElevation,
  [MutationNames.setCollectionEventGeolocation]: setCollectionEventGeolocation,
  [MutationNames.setCollectionEventHabitat]: setCollectionEventHabitat,
  [MutationNames.setCollectionEventLatitude]: setCollectionEventLatitude,
  [MutationNames.setCollectionEventLocality]: setCollectionEventLocality,
  [MutationNames.setCollectionEventLongitude]: setCollectionEventLongitude,
  [MutationNames.setCollectionEventMethod]: setCollectionEventMethod,
  [MutationNames.setCollectionEventTripIdentifier]: setCollectionEventTripIdentifier,
}

export {
  MutationNames,
  MutationFunctions
}
