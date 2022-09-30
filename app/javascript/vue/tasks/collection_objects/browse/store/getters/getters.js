import getGeoreferences from './getGeoreferences'
import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getIdentifiers from './getIdentifiers'

const GetterNames = {
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectonObject: 'getCollectionObject',
  GetGeoreferences: 'loadGeoreferences',
  GetIdentifiers: 'getIdentifiers'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetCollectonObject]: getCollectionObject,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetIdentifiers]: getIdentifiers
}

export {
  GetterNames,
  GetterFunctions
}
