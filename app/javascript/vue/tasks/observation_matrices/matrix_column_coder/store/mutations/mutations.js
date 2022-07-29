import addObservation from './addObservation'
import cleanObservation from './cleanObservation'
import countdownStartedFor from './countdownStartedFor'
import removeObservation from './removeObservation'
import setCharacterStateChecked from './setCharacterStateChecked'
import setContinuousUnit from './setContinuousUnit'
import setContinuousValue from './setContinuousValue'
import setObservation from './setObservation'
import setObservationId from './setObservationId'
import setObservationMatrix from './setObservationMatrix'
import setObservations from './setObservations'
import setRowObjectSavedOnce from './setRowObjectSavedOnce'
import setRowObjectSaving from './setRowObjectSaving'
import setRowObjectUnsaved from './setRowObjectUnsaved'

const MutationNames = {
  AddObservation: 'addObservation',
  CleanObservation: 'cleanObservation',
  CountdownStartedFor: 'countdownStartedFor',
  RemoveObservation: 'removeObservation',
  SetCharacterStateChecked: 'setCharacterStateChecked',
  SetContinuousUnit: 'setContinuousUnit',
  SetContinuousValue: 'setContinuousValue',
  SetObservation: 'setObservation',
  SetObservationId: 'setObservationId',
  SetObservationMatrix: 'setObservationMatrix',
  SetObservations: 'setObservations',
  SetRowObjectSavedOnce: 'setRowObjectSavedOnce',
  SetRowObjectSaving: 'setRowObjectSaving',
  SetRowObjectUnsaved: 'setRowObjectUnsaved'
}

const MutationFunctions = {
  [MutationNames.AddObservation]: addObservation,
  [MutationNames.CleanObservation]: cleanObservation,
  [MutationNames.CountdownStartedFor]: countdownStartedFor,
  [MutationNames.SetCharacterStateChecked]: setCharacterStateChecked,
  [MutationNames.SetObservation]: setObservation,
  [MutationNames.SetObservationId]: setObservationId,
  [MutationNames.SetObservations]: setObservations,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetRowObjectUnsaved]: setRowObjectUnsaved,
  [MutationNames.SetRowObjectSavedOnce]: setRowObjectSavedOnce,
  [MutationNames.SetRowObjectSaving]: setRowObjectSaving,
  [MutationNames.RemoveObservation]: removeObservation,
  [MutationNames.SetContinuousUnit]: setContinuousUnit,
  [MutationNames.SetContinuousValue]: setContinuousValue
}

export {
  MutationFunctions,
  MutationNames
}
