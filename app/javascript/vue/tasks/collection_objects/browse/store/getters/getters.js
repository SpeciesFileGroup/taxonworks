import getAnatomicalParts from './getAnatomicalParts'
import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getContainer from './getContainer'
import getConveyances from './getConveyances'
import getDepictions from './getDepictions'
import getDwc from './getDwc'
import getGeoreferences from './getGeoreferences'
import getIdentifiers from './getIdentifiers'
import getSoftValidations from './getSoftValidations'
import getTimeline from './getTimeline'
import getBiocurations from './getBiocurations'
import getDeterminations from './getDeterminations'
import getBiologicalAssociations from './getBiologicalAssociations'
import getTypeMaterials from './getTypeMaterials'
import getNavigation from './getNavigation'
import getGeographicArea from './getGeographicArea'
import getRepository from './getRepository'
import getCurrentRepository from './getCurrentRepository'

const GetterNames = {
  GetAnatomicalParts: 'getAnatomicalParts',
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectionObject: 'getCollectionObject',
  GetContainer: 'getContainer',
  GetConveyances: 'getConveyances',
  GetDepictions: 'getDepictions',
  GetDwc: 'getDwc',
  GetGeographicArea: 'getGeographicArea',
  GetGeoreferences: 'loadGeoreferences',
  GetIdentifiers: 'getIdentifiers',
  GetSoftValidations: 'getSoftValidations',
  GetTimeline: 'getTimeline',
  GetBiocurations: 'getBiocurations',
  GetDeterminations: 'getDeterminations',
  GetBiologicalAssociations: 'getBiologicalAssociations',
  GetTypeMaterials: 'getTypeMaterials',
  GetNavigation: 'getNavigation',
  GetRepository: 'getRepository',
  GetCurrentRepository: 'getCurrentRepository'
}

const GetterFunctions = {
  [GetterNames.GetAnatomicalParts]: getAnatomicalParts,
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetContainer]: getContainer,
  [GetterNames.GetConveyances]: getConveyances,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetDwc]: getDwc,
  [GetterNames.GetGeoreferences]: getGeoreferences,
  [GetterNames.GetGeographicArea]: getGeographicArea,
  [GetterNames.GetIdentifiers]: getIdentifiers,
  [GetterNames.GetSoftValidations]: getSoftValidations,
  [GetterNames.GetTimeline]: getTimeline,
  [GetterNames.GetBiocurations]: getBiocurations,
  [GetterNames.GetDeterminations]: getDeterminations,
  [GetterNames.GetBiologicalAssociations]: getBiologicalAssociations,
  [GetterNames.GetTypeMaterials]: getTypeMaterials,
  [GetterNames.GetNavigation]: getNavigation,
  [GetterNames.GetRepository]: getRepository,
  [GetterNames.GetCurrentRepository]: getCurrentRepository
}

export { GetterNames, GetterFunctions }
