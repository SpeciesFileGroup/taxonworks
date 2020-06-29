import setCollectingEvent from './setCollectingEvent'
import setPreferences from './setPreferences'
import setTripCode from './setTripCode'

const MutationNames = {
  SetCollectingEvent: 'setCollectingEvent',
  SetPreferences: 'setPreferences',
  SetTripCode: 'setTripCode'
}

const MutationFunctions = {
  [MutationNames.SetCollectingEvent]: setCollectingEvent,
  [MutationNames.SetPreferences]: setPreferences,
  [MutationNames.SetTripCode]: setTripCode
}

export {
  MutationNames,
  MutationFunctions
}