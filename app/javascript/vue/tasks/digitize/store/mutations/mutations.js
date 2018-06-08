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
import setCollectionEventElevationPrecision from './setCollectionEventElevationPrecision'
import setCollectionEventMaximumElevation from './setCollectionEventMaximumElevation'
import setCollectionEventMinimumElevation from './setCollectionEventMinimumElevation'

const MutationNames = {
  SetCollectionEventLabel: 'setCollectionEventLabel',
  SetCollectionEventCollectors: 'setCollectionEventCollectors',
  SetCollectionEventDate: 'setCollectionEventDate',
  SetCollectionEventDatum: 'setCollectionEventDatum',
  SetCollectionEventElevation: 'setCollectionEventElevation',
  SetCollectionEventGeolocation: 'setCollectionEventGeolocation',
  SetCollectionEventHabitat: 'setCollectionEventHabitat',
  SetCollectionEventLatitude: 'setCollectionEventLatitude',
  SetCollectionEventLocality: 'setCollectionEventLocality',
  SetCollectionEventLongitude: 'setCollectionEventLongitude',
  SetCollectionEventMethod: 'setCollectionEventMethod',
  SetCollectionEventTripIdentifier: 'setCollectionEventTripIdentifier',
  SetCollectionEventElevationPrecision: 'setCollectionEventElevationPrecision',
  SetCollectionEventMaximumElevation: 'setCollectionEventMaximumElevation',
  SetCollectionEventMinimumElevation: 'setCollectionEventMinimumElevation'
}

const MutationFunctions = {
  [MutationNames.SetCollectionEventLabel]: setCollectionEventLabel,
  [MutationNames.SetCollectionEventCollectors]: setCollectionEventCollectors,
  [MutationNames.SetCollectionEventDate]: setCollectionEventDate,
  [MutationNames.SetCollectionEventDatum]: setCollectionEventDatum,
  [MutationNames.SetCollectionEventElevation]: setCollectionEventElevation,
  [MutationNames.SetCollectionEventGeolocation]: setCollectionEventGeolocation,
  [MutationNames.SetCollectionEventHabitat]: setCollectionEventHabitat,
  [MutationNames.SetCollectionEventLatitude]: setCollectionEventLatitude,
  [MutationNames.SetCollectionEventLocality]: setCollectionEventLocality,
  [MutationNames.SetCollectionEventLongitude]: setCollectionEventLongitude,
  [MutationNames.SetCollectionEventMethod]: setCollectionEventMethod,
  [MutationNames.SetCollectionEventTripIdentifier]: setCollectionEventTripIdentifier,
  [MutationNames.SetCollectionEventElevationPrecision]: setCollectionEventElevationPrecision,
  [MutationNames.SetCollectionEventMaximumElevation]: setCollectionEventMaximumElevation,
  [MutationNames.SetCollectionEventMinimumElevation]: setCollectionEventMinimumElevation
}

export {
  MutationNames,
  MutationFunctions
}
