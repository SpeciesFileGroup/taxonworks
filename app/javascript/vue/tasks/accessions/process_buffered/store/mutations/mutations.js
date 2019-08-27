import setSettings from './setSettings'
import setSelection from './setSelection'
import setCollectionObject from './setCollectionObject'
import setCollectingEvent from './setCollectingEvent'
import setSqedDepictions from './setSqedDepictions'
import setNearbyCO from './setNearbyCO'

const MutationNames = {
  SetSettings: 'setSettings',
  SetSelection: 'setSelection',
  SetCollectingEvent: 'setCollectingEvent',
  SetCollectionObject: 'setCollectionObject',
  SetSqedDepictions: 'setSqedDepictions',
  SetNearbyCO: 'setNearbyCO'
}

const MutationFunctions = {
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSelection]: setSelection,
  [MutationNames.SetCollectingEvent]: setCollectingEvent,
  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetSqedDepictions]: setSqedDepictions,
  [MutationNames.SetNearbyCO]: setNearbyCO
}

export {
  MutationNames,
  MutationFunctions
}
