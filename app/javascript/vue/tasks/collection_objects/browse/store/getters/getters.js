import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getDepictions from './getDepictions'
import getDwc from './getDwc'
import getGeoreferences from './getGeoreferences'
import getIdentifiers from './getIdentifiers'
import getSoftValidations from './getSoftValidations'
import getTimeline from './getTimeline'
import getBiocurations from './getBiocurations'
import getDeterminations from './getDeterminations'

const GetterNames = {
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectionObject: 'getCollectionObject',
  GetDepictions: 'getDepictions',
  GetDwc: 'getDwc',
  GetGeoreferences: 'loadGeoreferences',
  GetIdentifiers: 'getIdentifiers',
  GetSoftValidations: 'getSoftValidations',
  GetTimeline: 'getTimeline',
  GetBiocurations: 'getBiocurations',
  GetDeterminations: 'getDeterminations'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetDwc]: getDwc,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetIdentifiers]: getIdentifiers,
  [GetterNames.GetSoftValidations]: getSoftValidations,
  [GetterNames.GetTimeline]: getTimeline,
  [GetterNames.GetBiocurations]: getBiocurations,
  [GetterNames.GetDeterminations]: getDeterminations
}

export {
  GetterNames,
  GetterFunctions
}
