import addObservation from './addObservation'
import setDescription from './setDescription'
import setDescriptors from './setDescriptors'
import setDescriptorUnsaved from './setDescriptorUnsaved'
import setFreeTextValue from './setFreeTextValue'
import setTaxonTitle from './setTaxonTitle'
import setTaxonId from './setTaxonId'
import setObservation from './setObservation'
import setContinuousValue from './setContinuousValue'
import setContinuousUnit from './setContinuousUnit'
import setPresence from './setPresence'
import setCharacterStateChecked from './setCharacterStateChecked'
import setSampleMaxFor from './setSampleMaxFor'
import setSampleMinFor from './setSampleMinFor'
import setSampleNFor from './setSampleNFor'
import setSampleUnitFor from './setSampleUnitFor'
import setSampleMedian from './setSampleMedian'
import setSampleStandardDeviation from './setSampleStandardDeviation'
import setSampleStandardMean from './setSampleStandardMean'
import setSampleStandardError from './setSampleStandardError'
import clearObservation from './clearObservation'
import observationSaved from './observationSaved'
import countdownStartedFor from './countdownStartedFor'
import setDescriptorSaving from './setDescriptorSaving'
import setDescriptorSavedOnce from './setDescriptorSavedOnce'
import setObservationId from './setObservationId'
import setMatrixRow from './setMatrixRow'
import setDayFor from './setDayFor'
import setMonthFor from './setMonthFor'
import setYearFor from './setYearFor'
import resetState from './resetState'
import setUnits from './setUnits'
import removeObservation from '../mutations/removeObservation'

export const MutationNames = {
  AddObservation: 'addObservation',
  SetDescription: 'setDescription',
  SetDescriptors: 'setDescriptors',
  SetDescriptorUnsaved: 'setDescriptorUnsaved',
  SetTaxonTitle: 'setTaxonTitle',
  SetTaxonId: 'setTaxonId',
  SetObservation: 'setObservation',
  SetContinuousValue: 'setContinuousValue',
  SetContinuousUnit: 'setContinuousUnit',
  SetFreeTextValue: 'setFreeTextValue',
  SetPresence: 'setPresence',
  SetCharacterStateChecked: 'setCharacterStateChecked',
  SetSampleMedian: 'setSampleMedian ',
  SetSampleStandardMean: 'setSampleStandardMean',
  SetSampleStandardDeviation: 'setSampleStandardDeviation',
  SetSampleStandardError: 'setSampleStandardError',
  SetSampleMaxFor: 'setSampleMaxFor',
  SetSampleMinFor: 'setSampleMinFor',
  SetSampleNFor: 'setSampleNFor',
  SetSampleUnitFor: 'setSampleUnitFor',
  SetMatrixRow: 'setMatrixRow',
  ClearObservation: 'clearObservation',
  ObservationSaved: 'observationSaved',
  CountdownStartedFor: 'countdownStartedFor',
  SetDescriptorSaving: 'setDescriptorSaving',
  SetDescriptorSavedOnce: 'setDescriptorSavedOnce',
  SetObservationId: 'setObservationId',
  ResetState: 'resetState',
  SetUnits: 'setUnits',
  SetDayFor: 'setDayFor',
  SetMonthFor: 'setMonthFor',
  SetYearFor: 'setYearFor',
  RemoveObservation: 'removeObservation'
}

export const MutationFunctions = {
  [MutationNames.AddObservation]: addObservation,
  [MutationNames.ResetState]: resetState,
  [MutationNames.SetDescription]: setDescription,
  [MutationNames.SetDescriptors]: setDescriptors,
  [MutationNames.SetDescriptorUnsaved]: setDescriptorUnsaved,
  [MutationNames.SetTaxonTitle]: setTaxonTitle,
  [MutationNames.SetTaxonId]: setTaxonId,
  [MutationNames.SetObservation]: setObservation,
  [MutationNames.SetContinuousValue]: setContinuousValue,
  [MutationNames.SetContinuousUnit]: setContinuousUnit,
  [MutationNames.SetFreeTextValue]: setFreeTextValue,
  [MutationNames.SetPresence]: setPresence,
  [MutationNames.SetCharacterStateChecked]: setCharacterStateChecked,
  [MutationNames.SetSampleMedian]: setSampleMedian,
  [MutationNames.SetSampleStandardMean]: setSampleStandardMean,
  [MutationNames.SetSampleStandardDeviation]: setSampleStandardDeviation,
  [MutationNames.SetSampleStandardError]: setSampleStandardError,
  [MutationNames.SetSampleMaxFor]: setSampleMaxFor,
  [MutationNames.SetSampleMinFor]: setSampleMinFor,
  [MutationNames.SetSampleNFor]: setSampleNFor,
  [MutationNames.SetSampleUnitFor]: setSampleUnitFor,
  [MutationNames.ClearObservation]: clearObservation,
  [MutationNames.ObservationSaved]: observationSaved,
  [MutationNames.CountdownStartedFor]: countdownStartedFor,
  [MutationNames.SetDescriptorSaving]: setDescriptorSaving,
  [MutationNames.SetDescriptorSavedOnce]: setDescriptorSavedOnce,
  [MutationNames.SetObservationId]: setObservationId,
  [MutationNames.SetMatrixRow]: setMatrixRow,
  [MutationNames.SetUnits]: setUnits,
  [MutationNames.SetDayFor]: setDayFor,
  [MutationNames.SetMonthFor]: setMonthFor,
  [MutationNames.SetYearFor]: setYearFor,
  [MutationNames.RemoveObservation]: removeObservation
}
