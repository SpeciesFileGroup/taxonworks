import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getDepictions from './getDepictions'
import getDwc from './getDwc'
import getGeoreferences from './getGeoreferences'
import getIdentifiersFor from './getIdentifiersFor'
import getSoftValidationFor from './getSoftValidationFor'
import getTimeline from './getTimeline'
import getBiocurations from './getBiocurations'

const GetterNames = {
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectionObject: 'getCollectionObject',
  GetDepictions: 'getDepictions',
  GetDwc: 'getDwc',
  GetGeoreferences: 'loadGeoreferences',
  GetIdentifiersFor: 'getIdentifiersFor',
  GetSoftValidationFor: 'getSoftValidationFor',
  GetTimeline: 'getTimeline',
  GetBiocurations: 'getBiocurations'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetDwc]: getDwc,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetIdentifiersFor]: getIdentifiersFor,
  [GetterNames.GetSoftValidationFor]: getSoftValidationFor,
  [GetterNames.GetTimeline]: getTimeline,
  [GetterNames.GetBiocurations]: getBiocurations
}

export {
  GetterNames,
  GetterFunctions
}
