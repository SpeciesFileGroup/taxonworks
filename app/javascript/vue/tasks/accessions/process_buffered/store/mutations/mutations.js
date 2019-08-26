import setSettings from './setSettings'
import setSelection from './setSelection'
import getCollectionObject from './setCollectionObject'
import getCollectingEvent from './setCollectingEvent'

const MutationNames = {
  SetSettings: 'setSettings',
  SetSelection: 'setSelection',
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectionObject: 'getCollectionObject'
}

const MutationFunctions = {
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSelection]: setSelection,
  [MutationNames.GetCollectingEvent]: getCollectingEvent,
  [MutationNames.GetCollectionObject]: getCollectionObject
}

export {
  MutationNames,
  MutationFunctions
}
