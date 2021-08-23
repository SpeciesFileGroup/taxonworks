import getCELabel from './getCELabel'
import getCollectingEvent from './getCollectingEvent'
import getGeoreferences from './getGeoreferences'
import getIdentifier from './getIdentifier'
import getQueueGeoreferences from './getQueueGeoreferences'
import getGeographicArea from './getGeographicArea'
import getSettings from './getSettings'
import getSoftValidations from './getSoftValidations'
import getUnit from './getUnit'
import isUnsaved from './isUnsaved'

const GetterNames = {
  GetCELabel: 'getCELabel',
  GetCollectingEvent: 'getCollectingEvent',
  GetGeographicArea: 'getGeographicArea',
  GetGeoreferences: 'getGeoreferences',
  GetIdentifier: 'getIdentifier',
  GetQueueGeoreferences: 'getQueueGeoreferences',
  GetSettings: 'getSetting',
  GetSoftValidations: 'getSoftValidations',
  GetUnit: 'getUnit',
  IsUnsaved: 'isUnsaved'
}

const GetterFunctions = {
  [GetterNames.GetCELabel]: getCELabel,
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetGeographicArea]: getGeographicArea,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetIdentifier]: getIdentifier,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetQueueGeoreferences]: getQueueGeoreferences,
  [GetterNames.GetSoftValidations]: getSoftValidations,
  [GetterNames.GetUnit]: getUnit,
  [GetterNames.IsUnsaved]: isUnsaved
}

export {
  GetterNames,
  GetterFunctions
}
