import getCollectingEvents from './getCollectingEvents'
import getCollectionObjects from './getCollectionObjects'
import getDescendants from './getDescendants'
import getGeoreferences from './getGeoreferences'
import getPreferences from './getPreferences'
import getUserId from './getUserId'

const GetterNames = {
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectingEvents: 'getCollectingEvents',
  GetDescendants: 'getDescendants',
  GetGeoreferences: 'getGeoreferences',
  GetPreferences: 'getPreferences',
  GetUserId: 'getUserId'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvents]: getCollectingEvents,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetDescendants]: getDescendants,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetUserId]: getUserId
}

export {
  GetterNames,
  GetterFunctions
}
