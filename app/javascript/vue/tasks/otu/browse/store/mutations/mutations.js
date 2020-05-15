import setCollectingEvents from './setCollectingEvents'
import setCollectionObjects from './setCollectionObjects'
import setGeoreferences from './setGeoreferences'
import setPreferences from './setPreferences'
import setAssertedDistributions from './setAssertedDistributions'
import setCurrentOtu from './setCurrentOtu'

const MutationNames = {
  SetCollectingEvents: 'setCollectingEvents',
  SetCollectionObjects: 'setCollectionObjects',
  SetGeoreferences: 'setGeoreferences',
  SetPreferences: 'setPreferences',
  SetAssertedDistributions: 'setAssertedDistributions',
  SetCurrentOtu: 'setCurrentOtu'
}

const MutationFunctions = {
  [MutationNames.SetCollectingEvents]: setCollectingEvents,
  [MutationNames.SetCollectionObjects]: setCollectionObjects,
  [MutationNames.SetGeoreferences]: setGeoreferences,
  [MutationNames.SetPreferences]: setPreferences,
  [MutationNames.SetAssertedDistributions]: setAssertedDistributions,
  [MutationNames.SetCurrentOtu]: setCurrentOtu
}

export {
  MutationNames,
  MutationFunctions
}
