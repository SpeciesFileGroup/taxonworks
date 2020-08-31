import getCollectingEvents from './getCollectingEvents'
import getCollectionObjects from './getCollectionObjects'
import getDescendants from './getDescendants'
import getGeoreferences from './getGeoreferences'
import getPreferences from './getPreferences'
import getUserId from './getUserId'
import getAssertedDistributions from './getAssertedDistributions'
import getCurrentOtu from './getCurrentOtu'
import getLoadState from './getLoadState'
import getTaxonName from './getTaxonName'

const GetterNames = {
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectingEvents: 'getCollectingEvents',
  GetDescendants: 'getDescendants',
  GetGeoreferences: 'getGeoreferences',
  GetPreferences: 'getPreferences',
  GetUserId: 'getUserId',
  GetAssertedDistributions: 'getAssertedDistributions',
  GetCurrentOtu: 'getCurrentOtu',
  GetLoadState: 'getLoadState',
  GetTaxonName: 'getTaxonName'
}

const GetterFunctions = {
  [GetterNames.GetCollectingEvents]: getCollectingEvents,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetDescendants]: getDescendants,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetUserId]: getUserId,
  [GetterNames.GetAssertedDistributions]: getAssertedDistributions,
  [GetterNames.GetCurrentOtu]: getCurrentOtu,
  [GetterNames.GetLoadState]: getLoadState,
  [GetterNames.GetTaxonName]: getTaxonName
}

export {
  GetterNames,
  GetterFunctions
}
