import addObservation from './addObservation'
import cleanObservation from './cleanObservation'
import countdownStartedFor from './countdownStartedFor'
import removeObservation from './removeObservation'
import setCharacterStateChecked from './setCharacterStateChecked'
import setContinuousUnit from './setContinuousUnit'
import setContinuousValue from './setContinuousValue'
import setDayFor from './setDayFor'
import setFreeTextValue from './setFreeTextValue'
import setMonthFor from './setMonthFor'
import setTimeFor from './setTimeFor'
import setObservation from './setObservation'
import setObservationId from './setObservationId'
import setObservationMatrix from './setObservationMatrix'
import setObservations from './setObservations'
import setRowObjectSavedOnce from './setRowObjectSavedOnce'
import setRowObjectSaving from './setRowObjectSaving'
import setRowObjectUnsaved from './setRowObjectUnsaved'
import setSampleMaxFor from './setSampleMaxFor'
import setSampleMedian from './setSampleMedian'
import setSampleMinFor from './setSampleMinFor'
import setSampleNFor from './setSampleNFor'
import setSampleStandardDeviation from './setSampleStandardDeviation'
import setSampleStandardError from './setSampleStandardError'
import setSampleStandardMean from './setSampleStandardMean'
import setSampleUnitFor from './setSampleUnitFor'
import setPresence from './setPresence'
import setYearFor from './setYearFor'
import setDisplayOnlyUnsecored from './options/setDisplayOnlyUnsecored'

const MutationNames = {
  AddObservation: 'addObservation',
  CleanObservation: 'cleanObservation',
  CountdownStartedFor: 'countdownStartedFor',
  RemoveObservation: 'removeObservation',
  SetCharacterStateChecked: 'setCharacterStateChecked',
  SetContinuousUnit: 'setContinuousUnit',
  SetContinuousValue: 'setContinuousValue',
  SetDayFor: 'setDayFor',
  SetFreeTextValue: 'setFreeTextValue',
  SetMonthFor: 'setMonthFor',
  SetTimeFor: 'setTimeFor',
  SetObservation: 'setObservation',
  SetObservationId: 'setObservationId',
  SetObservationMatrix: 'setObservationMatrix',
  SetObservations: 'setObservations',
  SetRowObjectSavedOnce: 'setRowObjectSavedOnce',
  SetRowObjectSaving: 'setRowObjectSaving',
  SetRowObjectUnsaved: 'setRowObjectUnsaved',
  SetSampleMaxFor: 'setSampleMaxFor',
  SetSampleMedian: 'setSampleMedian',
  SetSampleMinFor: 'setSampleMinFor',
  SetSampleNFor: 'setSampleNFor',
  SetSampleStandardDeviation: 'setSampleStandardDeviation',
  SetSampleStandardError: 'setSampleStandardError',
  SetSampleStandardMean: 'setSampleStandardMean',
  SetSampleUnitFor: 'setSampleUnitFor',
  SetPresence: 'setPresence',
  SetYearFor: 'setYearFor',
  SetDisplayOnlyUnsecored: 'setDisplayOnlyUnsecored'
}

const MutationFunctions = {
  [MutationNames.AddObservation]: addObservation,
  [MutationNames.CleanObservation]: cleanObservation,
  [MutationNames.CountdownStartedFor]: countdownStartedFor,
  [MutationNames.SetCharacterStateChecked]: setCharacterStateChecked,
  [MutationNames.SetDayFor]: setDayFor,
  [MutationNames.SetFreeTextValue]: setFreeTextValue,
  [MutationNames.SetMonthFor]: setMonthFor,
  [MutationNames.SetObservation]: setObservation,
  [MutationNames.SetObservationId]: setObservationId,
  [MutationNames.SetObservations]: setObservations,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetTimeFor]: setTimeFor,
  [MutationNames.SetRowObjectUnsaved]: setRowObjectUnsaved,
  [MutationNames.SetRowObjectSavedOnce]: setRowObjectSavedOnce,
  [MutationNames.SetRowObjectSaving]: setRowObjectSaving,
  [MutationNames.RemoveObservation]: removeObservation,
  [MutationNames.SetContinuousUnit]: setContinuousUnit,
  [MutationNames.SetContinuousValue]: setContinuousValue,
  [MutationNames.SetSampleMaxFor]: setSampleMaxFor,
  [MutationNames.SetSampleMedian]: setSampleMedian,
  [MutationNames.SetSampleMinFor]: setSampleMinFor,
  [MutationNames.SetSampleNFor]: setSampleNFor,
  [MutationNames.SetSampleStandardDeviation]: setSampleStandardDeviation,
  [MutationNames.SetSampleStandardError]: setSampleStandardError,
  [MutationNames.SetSampleStandardMean]: setSampleStandardMean,
  [MutationNames.SetSampleUnitFor]: setSampleUnitFor,
  [MutationNames.SetPresence]: setPresence,
  [MutationNames.SetYearFor]: setYearFor,
  [MutationNames.SetDisplayOnlyUnsecored]: setDisplayOnlyUnsecored
}

export {
  MutationFunctions,
  MutationNames
}
