import getBiologicalAssociations from './getBiologicalAssociations'
import getCollectingEvents from './getCollectingEvents'
import getCollectionObjects from './getCollectionObjects'
import getCommonNames from './getCommonNames'
import getDepictions from './getDepictions'
import getDescendants from './getDescendants'
import getGeoreferences from './getGeoreferences'
import getPreferences from './getPreferences'
import getUserId from './getUserId'
import getAssertedDistributions from './getAssertedDistributions'
import getCurrentOtu from './getCurrentOtu'
import getLoadState from './getLoadState'
import getTaxonName from './getTaxonName'
import getTaxonNames from './getTaxonNames'
import getOtus from './getOtus'
import getObservationsDepictions from './getObservationsDepictions'

const GetterNames = {
  GetBiologicalAssociations: 'getBiologicalAssociations',
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectingEvents: 'getCollectingEvents',
  GetCommonNames: 'getCommonNames',
  GetDepictions: 'getDepictions',
  GetDescendants: 'getDescendants',
  GetGeoreferences: 'getGeoreferences',
  GetPreferences: 'getPreferences',
  GetUserId: 'getUserId',
  GetAssertedDistributions: 'getAssertedDistributions',
  GetObservationsDepictions: 'getObservationsDepictions',
  GetCurrentOtu: 'getCurrentOtu',
  GetLoadState: 'getLoadState',
  GetTaxonName: 'getTaxonName',
  GetTaxonNames: 'getTaxonNames',
  GetOtus: 'getOtus'
}

const GetterFunctions = {
  [GetterNames.GetBiologicalAssociations]: getBiologicalAssociations,
  [GetterNames.GetCollectingEvents]: getCollectingEvents,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetCommonNames]: getCommonNames,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetDescendants]: getDescendants,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetUserId]: getUserId,
  [GetterNames.GetAssertedDistributions]: getAssertedDistributions,
  [GetterNames.GetCurrentOtu]: getCurrentOtu,
  [GetterNames.GetLoadState]: getLoadState,
  [GetterNames.GetTaxonName]: getTaxonName,
  [GetterNames.GetTaxonNames]: getTaxonNames,
  [GetterNames.GetOtus]: getOtus,
  [GetterNames.GetObservationsDepictions]: getObservationsDepictions
}

export {
  GetterNames,
  GetterFunctions
}
