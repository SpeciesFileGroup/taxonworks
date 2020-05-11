import getCollectingEvents from './getCollectingEvents'
import getCollectionObjects from './getCollectionObjects'
import getDescendants from './getDescendants'
import getGeoreferences from './getGeoreferences'

const GetterNames = {
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectingEvents: 'getCollectingEvents',
  GetDescendants: 'getDescendants',
  GetGeoreferences: 'getGeoreferences'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvents]: getCollectingEvents,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetDescendants]: getDescendants,
  [GetterNames.GetGeoreferences]: getGeoreferences
}

export {
  GetterNames,
  GetterFunctions
}
