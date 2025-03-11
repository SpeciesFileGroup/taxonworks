import getBiologicalAssociations from './getBiologicalAssociations'
import getCachedMap from './getCachedMap'
import getCollectingEvents from './getCollectingEvents'
import getCollectionObjects from './getCollectionObjects'
import getCommonNames from './getCommonNames'
import getConveyances from './getConveyances'
import getDepictions from './getDepictions'
import getDescendants from './getDescendants'
import getGeoreferences from './getGeoreferences'
import getPreferences from './getPreferences'
import getUserId from './getUserId'
import getAssertedDistributions from './getAssertedDistributions'
import getCurrentOtu from './getCurrentOtu'
import getFieldOccurrences from './getFieldOccurrences'
import getLoadState from './getLoadState'
import getTaxonName from './getTaxonName'
import getTaxonNames from './getTaxonNames'
import getOtus from './getOtus'
import getObservationsDepictions from './getObservationsDepictions'
import getRelatedBiologicalAssociations from './getRelatedBiologicalAssociations'
import isSpeciesGroup from './isSpeciesGroup'

const GetterNames = {
  GetBiologicalAssociations: 'getBiologicalAssociations',
  GetCachedMap: 'getCachedMap',
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectingEvents: 'getCollectingEvents',
  GetCommonNames: 'getCommonNames',
  GetConveyances: 'getConveyances',
  GetDepictions: 'getDepictions',
  GetDescendants: 'getDescendants',
  GetGeoreferences: 'getGeoreferences',
  GetFieldOccurrences: 'getFieldOccurrences',
  GetPreferences: 'getPreferences',
  GetUserId: 'getUserId',
  GetAssertedDistributions: 'getAssertedDistributions',
  GetRelatedBiologicalAssociations: 'getRelatedBiologicalAssociations',
  GetObservationsDepictions: 'getObservationsDepictions',
  GetCurrentOtu: 'getCurrentOtu',
  GetLoadState: 'getLoadState',
  GetTaxonName: 'getTaxonName',
  GetTaxonNames: 'getTaxonNames',
  GetOtus: 'getOtus',
  IsSpeciesGroup: 'isSpeciesGroup'
}

const GetterFunctions = {
  [GetterNames.GetBiologicalAssociations]: getBiologicalAssociations,
  [GetterNames.GetCachedMap]: getCachedMap,
  [GetterNames.GetCollectingEvents]: getCollectingEvents,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetCommonNames]: getCommonNames,
  [GetterNames.GetConveyances]: getConveyances,
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
  [GetterNames.GetObservationsDepictions]: getObservationsDepictions,
  [GetterNames.GetRelatedBiologicalAssociations]:
    getRelatedBiologicalAssociations,
  [GetterNames.GetFieldOccurrences]: getFieldOccurrences,
  [GetterNames.IsSpeciesGroup]: isSpeciesGroup
}

export { GetterNames, GetterFunctions }
