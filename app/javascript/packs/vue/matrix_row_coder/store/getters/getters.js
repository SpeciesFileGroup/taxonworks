export const GetterNames = {
    GetObservationsFor: 'getObservationsFor',
    GetContinuousValueFor: 'getContinuousValueFor',
    GetContinuousUnitFor: 'getContinuousUnitFor',
    GetPresenceFor: 'getPresenceFor',
    GetSampleMinFor: 'getSampleMinFor',
    GetSampleMaxFor: 'getSampleMaxFor',
    GetSampleUnitFor: 'getSampleUnitFor',
    GetSampleNFor: 'getSampleNFor',
    GetCharacterStateChecked: `getCharacterStateChecked`,
    IsDescriptorUnsaved: 'isDescriptorUnsaved',
    DoesDescriptorNeedCountdown: 'doesDescriptorNeedCountdown'
};


import getObservationsFor from './getObservationsFor';
import getContinuousValueFor from './getContinuousValueFor';
import getContinuousUnitFor from './getContinuousUnitFor';
import getPresenceFor from './getPresenceFor';
import getSampleMinFor from './getSampleMinFor';
import getSampleMaxFor from './getSampleMaxFor';
import getSampleUnitFor from './getSampleUnitFor';
import getSampleNFor from './getSampleNFor';
import getCharacterStateChecked from './getCharacterStateChecked';
import isDescriptorUnsaved from './isDescriptorUnsaved';
import doesDescriptorNeedCountdown from './doesDescriptorNeedCountdown';

export const GetterFunctions = {
    [GetterNames.GetObservationsFor]: getObservationsFor,
    [GetterNames.GetContinuousValueFor]: getContinuousValueFor,
    [GetterNames.GetContinuousUnitFor]: getContinuousUnitFor,
    [GetterNames.GetPresenceFor]: getPresenceFor,
    [GetterNames.GetSampleMinFor]: getSampleMinFor,
    [GetterNames.GetSampleMaxFor]: getSampleMaxFor,
    [GetterNames.GetSampleUnitFor]: getSampleUnitFor,
    [GetterNames.GetSampleNFor]: getSampleNFor,
    [GetterNames.GetCharacterStateChecked]: getCharacterStateChecked,
    [GetterNames.IsDescriptorUnsaved]: isDescriptorUnsaved,
    [GetterNames.DoesDescriptorNeedCountdown]: doesDescriptorNeedCountdown,
};