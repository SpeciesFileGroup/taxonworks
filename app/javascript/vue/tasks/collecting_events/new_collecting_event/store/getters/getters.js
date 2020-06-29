import getCollectingEvent from './getCollectingEvent'
import getTripCode from './getTripCode'

const GetterNames = {
  GetCollectingEvent: 'getCollectingEvent',
  GetTripCode: 'getTripCode'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetTripCode]: getTripCode
}

export {
  GetterNames,
  GetterFunctions
}
