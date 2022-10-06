import getGeoreferences from './getGeoreferences'
import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getIdentifiers from './getIdentifiers'
import getDwc from './getDwc'
import getTimeline from './getTimeline'

const GetterNames = {
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectionObject: 'getCollectionObject',
  GetDwc: 'getDwc',
  GetGeoreferences: 'loadGeoreferences',
  GetIdentifiers: 'getIdentifiers',
  GetTimeline: 'getTimeline'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetDwc]: getDwc,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetIdentifiers]: getIdentifiers,
  [GetterNames.GetTimeline]: getTimeline
}

export {
  GetterNames,
  GetterFunctions
}
