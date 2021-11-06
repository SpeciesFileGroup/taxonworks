import addGeoreference from './addGeoreference'
import addGeoreferenceToQueue from './addGeoreferenceToQueue'
import setCELabel from './setCELabel'
import setCollectingEvent from './setCollectingEvent'
import setGeographicArea from './setGeographicArea'
import setGeoreferences from './setGeoreferences'
import setIdentifier from './setIdentifier'
import setQueueGeoreferences from './setQueueGeoreferences'
import setSoftValidations from './setSoftValidations'
import setStore from './setStore'
import updateLastChange from './updateLastChange'
import updateLastSave from './updateLastSave'
import setUnit from './setUnit'

const MutationNames = {
  AddGeoreference: 'addGeoreference',
  AddGeoreferenceToQueue: 'addGeoreferenceToQueue',
  SetCELabel: 'setCELabel',
  SetCollectingEvent: 'setCollectingEvent',
  SetGeographicArea: 'setGeographicArea',
  SetGeoreferences: 'setGeoreferences',
  SetIdentifier: 'setIdentifier',
  SetQueueGeoreferences: 'setQueueGeoreferences',
  SetSoftValidations: 'setSoftValidations',
  SetStore: 'setStore',
  UpdateLastChange: 'updateLastChange',
  UpdateLastSave: 'updateLastSave',
  SetUnit: 'setUnit'
}

const MutationFunctions = {
  [MutationNames.AddGeoreference]: addGeoreference,
  [MutationNames.AddGeoreferenceToQueue]: addGeoreferenceToQueue,
  [MutationNames.SetCELabel]: setCELabel,
  [MutationNames.SetCollectingEvent]: setCollectingEvent,
  [MutationNames.SetGeographicArea]: setGeographicArea,
  [MutationNames.SetGeoreferences]: setGeoreferences,
  [MutationNames.SetIdentifier]: setIdentifier,
  [MutationNames.SetQueueGeoreferences]: setQueueGeoreferences,
  [MutationNames.SetSoftValidations]: setSoftValidations,
  [MutationNames.SetStore]: setStore,
  [MutationNames.SetUnit]: setUnit,
  [MutationNames.UpdateLastChange]: updateLastChange,
  [MutationNames.UpdateLastSave]: updateLastSave
}

export {
  MutationNames,
  MutationFunctions
}
