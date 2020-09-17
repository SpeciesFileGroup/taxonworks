import setCollectingEvents from './setCollectingEvents'
import setCollectionObjects from './setCollectionObjects'
import setGeoreferences from './setGeoreferences'
import setPreferences from './setPreferences'
import setAssertedDistributions from './setAssertedDistributions'
import setCurrentOtu from './setCurrentOtu'
import setDescendants from './setDescendants'
import setLoadState from './setLoadState'
import setTaxonName from './setTaxonName'

const MutationNames = {
  SetCollectingEvents: 'setCollectingEvents',
  SetCollectionObjects: 'setCollectionObjects',
  SetGeoreferences: 'setGeoreferences',
  SetPreferences: 'setPreferences',
  SetAssertedDistributions: 'setAssertedDistributions',
  SetCurrentOtu: 'setCurrentOtu',
  SetDescendants: 'setDescendants',
  SetLoadState: 'setLoadState',
  SetTaxonName: 'setTaxonName'
}

const MutationFunctions = {
  [MutationNames.SetCollectingEvents]: setCollectingEvents,
  [MutationNames.SetCollectionObjects]: setCollectionObjects,
  [MutationNames.SetGeoreferences]: setGeoreferences,
  [MutationNames.SetPreferences]: setPreferences,
  [MutationNames.SetAssertedDistributions]: setAssertedDistributions,
  [MutationNames.SetCurrentOtu]: setCurrentOtu,
  [MutationNames.SetDescendants]: setDescendants,
  [MutationNames.SetLoadState]: setLoadState,
  [MutationNames.SetTaxonName]: setTaxonName
}

export {
  MutationNames,
  MutationFunctions
}
