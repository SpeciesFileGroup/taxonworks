import setSettings from './setSettings'
import setSelection from './setSelection'
import setCollectionObject from './setCollectionObject'
import setCollectingEvent from './setCollectingEvent'

const MutationNames = {
  SetSettings: 'setSettings',
  SetSelection: 'setSelection',
  SetCollectingEvent: 'setCollectingEvent',
  SetCollectionObject: 'setCollectionObject'
}

const MutationFunctions = {
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSelection]: setSelection,
  [MutationNames.SetCollectingEvent]: setCollectingEvent,
  [MutationNames.SetCollectionObject]: setCollectionObject
}

export {
  MutationNames,
  MutationFunctions
}
