import getSettings from './getSettings'
import getSelection from './getSelection'
import getCollectionObject from './getCollectionObject'
import getCollectingEvent from './getCollectingEvent'

const GetterNames = {
  GetSettings: 'getSeetings',
  GetSelection: 'getSelection',
  GetCollectionObject: 'getCollectionObject',
  GetCollectingEvent: 'getCollectingEvent'
}

const GetterFunctions = {
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSelection]: getSelection,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetCollectingEvent]: getCollectingEvent
}

export {
  GetterNames,
  GetterFunctions
}
