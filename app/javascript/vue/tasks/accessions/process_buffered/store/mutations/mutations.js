import setSettings from './setSettings'
import setSelection from './setSelection'
import setCollectionObject from './setCollectionObject'
import setCollectingEvent from './setCollectingEvent'
import setSqedDepictions from './setSqedDepictions'
import setNearbyCO from './setNearbyCO'
import setTypeSelected from './setTypeSelected'

const MutationNames = {
  SetSettings: 'setSettings',
  SetSelection: 'setSelection',
  SetCollectingEvent: 'setCollectingEvent',
  SetCollectionObject: 'setCollectionObject',
  SetSqedDepictions: 'setSqedDepictions',
  SetNearbyCO: 'setNearbyCO',
  SetTypeSelected: 'setTypeSelected'
}

const MutationFunctions = {
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSelection]: setSelection,
  [MutationNames.SetCollectingEvent]: setCollectingEvent,
  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetSqedDepictions]: setSqedDepictions,
  [MutationNames.SetNearbyCO]: setNearbyCO,
  [MutationNames.SetTypeSelected]: setTypeSelected
}

export {
  MutationNames,
  MutationFunctions
}
