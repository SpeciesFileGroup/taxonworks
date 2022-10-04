import getGeoreferences from './getGeoreferences'
import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getIdentifiers from './getIdentifiers'
import getDwc from './getDwc'

const GetterNames = {
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectonObject: 'getCollectionObject',
  GetDwc: 'getDwc',
  GetGeoreferences: 'loadGeoreferences',
  GetIdentifiers: 'getIdentifiers'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetCollectonObject]: getCollectionObject,
  [GetterNames.GetDwc]: getDwc,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetIdentifiers]: getIdentifiers
}

export {
  GetterNames,
  GetterFunctions
}
