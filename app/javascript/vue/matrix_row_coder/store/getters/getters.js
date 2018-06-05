export const GetterNames = {
  GetObservationsFor: 'getObservationsFor',
  GetContinuousValueFor: 'getContinuousValueFor',
  GetContinuousUnitFor: 'getContinuousUnitFor',
  GetPresenceFor: 'getPresenceFor',
  GetSampleMinFor: 'getSampleMinFor',
  GetSampleMaxFor: 'getSampleMaxFor',
  GetSampleUnitFor: 'getSampleUnitFor',
  GetSampleNFor: 'getSampleNFor',
  GetMatrixRow: 'getMatrixRow',
  GetCharacterStateChecked: `getCharacterStateChecked`,
  IsDescriptorUnsaved: 'isDescriptorUnsaved',
  IsDescriptorSaving: 'isDescriptorSaving',
  DoesDescriptorNeedCountdown: 'doesDescriptorNeedCountdown'
}

import getObservationsFor from './getObservationsFor'
import getContinuousValueFor from './getContinuousValueFor'
import getContinuousUnitFor from './getContinuousUnitFor'
import getPresenceFor from './getPresenceFor'
import getSampleMinFor from './getSampleMinFor'
import getSampleMaxFor from './getSampleMaxFor'
import getSampleUnitFor from './getSampleUnitFor'
import getSampleNFor from './getSampleNFor'
import getCharacterStateChecked from './getCharacterStateChecked'
import isDescriptorUnsaved from './isDescriptorUnsaved'
import isDescriptorSaving from './isDescriptorSaving'
import doesDescriptorNeedCountdown from './doesDescriptorNeedCountdown'
import getMatrixRow from './getMatrixRow'

export const GetterFunctions = {
  [GetterNames.GetObservationsFor]: getObservationsFor,
  [GetterNames.GetContinuousValueFor]: getContinuousValueFor,
  [GetterNames.GetContinuousUnitFor]: getContinuousUnitFor,
  [GetterNames.GetPresenceFor]: getPresenceFor,
  [GetterNames.GetSampleMinFor]: getSampleMinFor,
  [GetterNames.GetSampleMaxFor]: getSampleMaxFor,
  [GetterNames.GetSampleUnitFor]: getSampleUnitFor,
  [GetterNames.GetSampleNFor]: getSampleNFor,
  [GetterNames.GetMatrixRow]: getMatrixRow,
  [GetterNames.GetCharacterStateChecked]: getCharacterStateChecked,
  [GetterNames.IsDescriptorUnsaved]: isDescriptorUnsaved,
  [GetterNames.IsDescriptorSaving]: isDescriptorSaving,
  [GetterNames.DoesDescriptorNeedCountdown]: doesDescriptorNeedCountdown
}
