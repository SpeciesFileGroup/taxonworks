import setCollectingEvents from './setCollectingEvents'
import setCollectionObjects from './setCollectionObjects'
import setGeoreferences from './setGeoreferences'

const MutationNames = {
  SetCollectingEvents: 'setCollectingEvents',
  SetCollectionObjects: 'setCollectionObjects',
  SetGeoreferences: 'setGeoreferences'
}

const MutationFunctions = {
  [MutationNames.SetCollectingEvents]: setCollectingEvents,
  [MutationNames.SetCollectionObjects]: setCollectionObjects,
  [MutationNames.SetGeoreferences]: setGeoreferences
}

export {
  MutationNames,
  MutationFunctions
}
