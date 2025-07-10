import isSaving from './isSaving'
import isLoading from './isLoading'
import getLocked from './getLocked'
import getSettings from './getSettings'
import getCOCitations from './getCOCitations'
import getCollectionObject from './getCollectionObject'
import getCollectionObjects from './getCollectionObjects'
import getComponentsOrder from './getComponentsOrder'
import getTypeMaterial from './getTypeMaterial'
import getTypeMaterials from './getTypeMaterials'
import getTypeSpecimens from './getTypeSpecimens'
import getDepictions from './getDepictions'
import getContainer from './getContainer'
import getContainerItems from './getContainerItems'
import getPreferences from './getPreferences'
import getBiocurations from './getBiocurations'
import getMaterialTypes from './getMaterialTypes'
import getSubsequentialUses from './getSubsequentialUses'
import getProjectPreferences from './getProjectPreferences'
import getLastSave from './getLastSave'
import getSoftValidations from './getSoftValidations'

const GetterNames = {
  IsSaving: 'isSaving',
  IsLoading: 'isLoading',
  GetLocked: 'getLocked',
  GetSettings: 'getSettings',
  GetCOCitations: 'getCOCitations',
  GetCollectionObject: 'getCollectionObject',
  GetCollectionObjects: 'getCollectionObjects',
  GetComponentsOrder: 'getComponentsOrder',
  GetTypeMaterial: 'getTypeMaterial',
  GetTypeMaterials: 'getTypeMaterials',
  GetTypeSpecimens: 'getTypeSpecimens',
  GetDepictions: 'getDepictions',
  GetContainer: 'getContainer',
  GetContainerItems: 'getContainerItems',
  GetPreferences: 'getPreferences',
  GetBiocurations: 'getBiocurations',
  GetMaterialTypes: 'getMaterialTypes',
  GetSubsequentialUses: 'getSubsequentialUses',
  GetProjectPreferences: 'getProjectPreferences',
  GetLastSave: 'getLastSave',
  GetSoftValidations: 'getSoftValidations'
}

const GetterFunctions = {
  [GetterNames.IsSaving]: isSaving,
  [GetterNames.IsLoading]: isLoading,
  [GetterNames.GetLocked]: getLocked,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetCOCitations]: getCOCitations,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetTypeMaterial]: getTypeMaterial,
  [GetterNames.GetTypeMaterials]: getTypeMaterials,
  [GetterNames.GetTypeSpecimens]: getTypeSpecimens,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetContainer]: getContainer,
  [GetterNames.GetContainerItems]: getContainerItems,
  [GetterNames.GetComponentsOrder]: getComponentsOrder,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetBiocurations]: getBiocurations,
  [GetterNames.GetMaterialTypes]: getMaterialTypes,
  [GetterNames.GetSubsequentialUses]: getSubsequentialUses,
  [GetterNames.GetProjectPreferences]: getProjectPreferences,
  [GetterNames.GetLastSave]: getLastSave,
  [GetterNames.GetSoftValidations]: getSoftValidations
}

export { GetterNames, GetterFunctions }
