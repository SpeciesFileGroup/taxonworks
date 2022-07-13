import areDescriptorsUnsaved from './areDescriptorsUnsaved'
import getDescription from './getDescription'
import getFreeTextValueFor from './getFreeTextValueFor'
import getObservationsFor from './getObservationsFor'
import getContinuousValueFor from './getContinuousValueFor'
import getContinuousUnitFor from './getContinuousUnitFor'
import getPresenceFor from './getPresenceFor'
import getSampleMinFor from './getSampleMinFor'
import getSampleMaxFor from './getSampleMaxFor'
import getSampleUnitFor from './getSampleUnitFor'
import getSampleNFor from './getSampleNFor'
import getSampleMedian from './getSampleMedian'
import getSampleStandardError from './getSampleStandardError'
import getSampleStandardDeviation from './getSampleStandardDeviation'
import getSampleStandardMean from './getSampleStandardMean'
import getCharacterStateChecked from './getCharacterStateChecked'
import isDescriptorUnsaved from './isDescriptorUnsaved'
import isDescriptorSaving from './isDescriptorSaving'
import doesDescriptorNeedCountdown from './doesDescriptorNeedCountdown'
import getMatrixRow from './getMatrixRow'
import getUnits from './getUnits'
import getObservations from './getObservations'

export const GetterNames = {
  AreDescriptorsUnsaved: 'areDescriptorsUnsaved',
  GetDescription: 'getDescription',
  GetFreeTextValueFor: 'getFreeTextValueFor',
  GetObservationsFor: 'getObservationsFor',
  GetContinuousValueFor: 'getContinuousValueFor',
  GetContinuousUnitFor: 'getContinuousUnitFor',
  GetPresenceFor: 'getPresenceFor',
  GetSampleMinFor: 'getSampleMinFor',
  GetSampleMaxFor: 'getSampleMaxFor',
  GetSampleUnitFor: 'getSampleUnitFor',
  GetSampleNFor: 'getSampleNFor',
  GetSampleMedian: 'getSampleMedian',
  GetSampleStandardDeviation: 'getSampleStandardDeviation',
  GetSampleStandardError: 'getSampleStandardError',
  GetSampleStandardMean: 'getSampleStandardMean',
  GetMatrixRow: 'getMatrixRow',
  GetCharacterStateChecked: 'getCharacterStateChecked',
  IsDescriptorUnsaved: 'isDescriptorUnsaved',
  IsDescriptorSaving: 'isDescriptorSaving',
  DoesDescriptorNeedCountdown: 'doesDescriptorNeedCountdown',
  GetUnits: 'getUnits',
  GetObservations: 'getObservations'
}

export const GetterFunctions = {
  [GetterNames.AreDescriptorsUnsaved]: areDescriptorsUnsaved,
  [GetterNames.GetDescription]: getDescription,
  [GetterNames.GetFreeTextValueFor]: getFreeTextValueFor,
  [GetterNames.GetObservationsFor]: getObservationsFor,
  [GetterNames.GetContinuousValueFor]: getContinuousValueFor,
  [GetterNames.GetContinuousUnitFor]: getContinuousUnitFor,
  [GetterNames.GetPresenceFor]: getPresenceFor,
  [GetterNames.GetSampleMinFor]: getSampleMinFor,
  [GetterNames.GetSampleMaxFor]: getSampleMaxFor,
  [GetterNames.GetSampleUnitFor]: getSampleUnitFor,
  [GetterNames.GetSampleNFor]: getSampleNFor,
  [GetterNames.GetSampleMedian]: getSampleMedian,
  [GetterNames.GetSampleStandardMean]: getSampleStandardMean,
  [GetterNames.GetSampleStandardDeviation]: getSampleStandardDeviation,
  [GetterNames.GetSampleStandardError]: getSampleStandardError,
  [GetterNames.GetMatrixRow]: getMatrixRow,
  [GetterNames.GetCharacterStateChecked]: getCharacterStateChecked,
  [GetterNames.IsDescriptorUnsaved]: isDescriptorUnsaved,
  [GetterNames.IsDescriptorSaving]: isDescriptorSaving,
  [GetterNames.DoesDescriptorNeedCountdown]: doesDescriptorNeedCountdown,
  [GetterNames.GetUnits]: getUnits,
  [GetterNames.GetObservations]: getObservations
}
