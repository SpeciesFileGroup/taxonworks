import isSaving from './isSaving'
import isLoading from './isLoading'
import getLocked from './getLocked'
import getSettings from './getSettings'
import getCOCitations from './getCOCitations'
import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getCollectionObjects from './getCollectionObjects'
import getCollectingEventLabel from './getCollectingEventLabel'
import getComponentsOrder from './getComponentsOrder'
import getTypeMaterial from './getTypeMaterial'
import getTypeMaterials from './getTypeMaterials'
import getDepictions from './getDepictions'
import getIdentifier from './getIdentifier'
import getIdentifiers from './getIdentifiers'
import getContainer from './getContainer'
import getContainerItems from './getContainerItems'
import getPreferences from './getPreferences'
import getBiocurations from './getBiocurations'
import getMaterialTypes from './getMaterialTypes'
import getLabel from './getLabel'
import getTaxonDeterminations from './getTaxonDeterminations'
import getNamespaceSelected from './getNamespaceSelected'
import getSubsequentialUses from './getSubsequentialUses'
import getCollectingEventIdentifier from './getCollectingEventIdentifier'
import getGeographicArea from './getGeographicArea'
import getProjectPreferences from './getProjectPreferences'
import getLastSave from './getLastSave'
import getSoftValidations from './getSoftValidations'
import getBiologicalAssociations from './getBiologicalAssociations'
import getGeoreferences from './getGeoreferences'

const GetterNames = {
  IsSaving: 'isSaving',
  IsLoading: 'isLoading',
  GetLocked: 'getLocked',
  GetSettings: 'getSettings',
  GetCOCitations: 'getCOCitations',
  GetCollectingEventIdentifier: 'getCollectingEventIdentifier',
  GetCollectingEvent: 'getCollectingEvent',
  GetCollectionObject: 'getCollectionObject',
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectingEventLabel: 'getCollectingEventLabel',
  GetComponentsOrder: 'getComponentsOrder',
  GetGeographicArea: 'getGeographicArea',
  GetTypeMaterial: 'getTypeMaterial',
  GetTypeMaterials: 'getTypeMaterials',
  GetDepictions: 'getDepictions',
  GetIdentifier: 'getIdentifier',
  GetIdentifiers: 'getIdentifiers',
  GetContainer: 'getContainer',
  GetContainerItems: 'getContainerItems',
  GetPreferences: 'getPreferences',
  GetBiocurations: 'getBiocurations',
  GetMaterialTypes: 'getMaterialTypes',
  GetLabel: 'GetLabel',
  GetTaxonDeterminations: 'GetTaxonDeterminations',
  GetNamespaceSelected: 'getNamespaceSelected',
  GetSubsequentialUses: 'getSubsequentialUses',
  GetProjectPreferences: 'getProjectPreferences',
  GetLastSave: 'getLastSave',
  GetSoftValidations: 'getSoftValidations',
  GetBiologicalAssociations: 'getBiologicalAssociations',
  GetGeoreferences: 'getGeoreferences'
}

const GetterFunctions = {
  [GetterNames.IsSaving]: isSaving,
  [GetterNames.IsLoading]: isLoading,
  [GetterNames.GetLocked]: getLocked,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetGeographicArea]: getGeographicArea,
  [GetterNames.GetCOCitations]: getCOCitations,
  [GetterNames.GetCollectingEventLabel]: getCollectingEventLabel,
  [GetterNames.GetCollectingEventIdentifier]: getCollectingEventIdentifier,
  [GetterNames.GetCollectingEvent]: getCollectingEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetTypeMaterial]: getTypeMaterial,
  [GetterNames.GetTypeMaterials]: getTypeMaterials,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetIdentifier]: getIdentifier,
  [GetterNames.GetIdentifiers]: getIdentifiers,
  [GetterNames.GetContainer]: getContainer,
  [GetterNames.GetContainerItems]: getContainerItems,
  [GetterNames.GetComponentsOrder]: getComponentsOrder,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetBiocurations]: getBiocurations,
  [GetterNames.GetMaterialTypes]: getMaterialTypes,
  [GetterNames.GetLabel]: getLabel,
  [GetterNames.GetTaxonDeterminations]: getTaxonDeterminations,
  [GetterNames.GetNamespaceSelected]: getNamespaceSelected,
  [GetterNames.GetSubsequentialUses]: getSubsequentialUses,
  [GetterNames.GetProjectPreferences]: getProjectPreferences,
  [GetterNames.GetLastSave]: getLastSave,
  [GetterNames.GetSoftValidations]: getSoftValidations,
  [GetterNames.GetBiologicalAssociations]: getBiologicalAssociations,
  [GetterNames.GetGeoreferences]: getGeoreferences
}

export {
  GetterNames,
  GetterFunctions
}
