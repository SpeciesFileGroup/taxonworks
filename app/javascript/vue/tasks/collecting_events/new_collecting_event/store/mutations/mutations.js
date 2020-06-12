import setCollectingEvent from './setCollectingEvent'

const MutationNames = {
  SetCollectingEvent: 'setCollectingEvent'
}

const MutationFunctions = {
  [MutationNames.SetCollectingEvent]: setCollectingEvent
}

export {
  MutationNames,
  MutationFunctions
}