import getSettings from './getSettings'
import getSelection from './getSelection'
import getCollectionObject from './getCollectionObject'
import getCollectingEvent from './getCollectingEvent'
import getSqedDepictions from './getSqedDepictions'
import getNearbyCO from './getNearbyCO'
import getTypeSelected from './getTypeSelected'

const GetterNames = {
  GetSettings: 'getSeetings',
  GetSelection: 'getSelection',
  GetCollectionObject: 'getCollectionObject',
  GetCollectingEvent: 'getCollectingEvent',
  GetSqedDepictions: 'getSqedDepictions',
  GetNearbyCO: 'getNearbyCO',
  GetTypeSelected: 'getTypeSelected'
}

const GetterFunctions = {
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSelection]: getSelection,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetSqedDepictions]: getSqedDepictions,
  [GetterNames.GetNearbyCO]: getNearbyCO,
  [GetterNames.GetTypeSelected]: getTypeSelected
}

export {
  GetterNames,
  GetterFunctions
}
