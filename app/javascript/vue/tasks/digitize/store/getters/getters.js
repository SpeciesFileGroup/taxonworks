import isSaving from './isSaving'
import getLocked from './getLocked'
import getSettings from './getSettings'
import getCollectionEvent from './getCollectionEvent'
import getCollectionObject from './getCollectionObject'
import getCollectionObjects from './getCollectionObjects'
import getCollectionEventLabel from './getCollectionEventLabel'
import getTypeMaterial from './getTypeMaterial'
import getDepictions from './getDepictions'
import getIdentifier from './getIdentifier'
import getIdentifiers from './getIdentifiers'
import getContainer from './getContainer'
import getContainerItems from './getContainerItems'
import getTaxonDetermination from './getTaxonDetermination'
import getCollectionObjectTypes from './getCollectionObjectTypes'
import getPreferences from './getPreferences'
import getBiocurations from './getBiocurations'
import getPreparationType from './getPreparationType'
import getMaterialTypes from './getMaterialTypes'
import getLabel from './getLabel'
import getTaxonDeterminations from './getTaxonDeterminations'
import getNamespaceSelected from './getNamespaceSelected'

const GetterNames = {
  IsSaving: 'isSaving',
  GetLocked: 'getLocked',
  GetSettings: 'getSettings',
  GetTaxonDetermination: 'getTaxonDetermination',
  GetCollectionEvent: 'getCollectionEvent',
  GetCollectionObject: 'getCollectionObject',
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectionEventLabel: 'getCollectionEventLabel',
  GetTypeMaterial: 'getTypeMaterial',
  GetDepictions: 'getDepictions',
  GetIdentifier: 'getIdentifier',
  GetIdentifiers: 'getIdentifiers',
  GetContainer: 'getContainer',
  GetContainerItems: 'getContainerItems',
  GetCollectionObjectTypes: 'getCollectionObjectTypes',
  GetPreferences: 'getPreferences',
  GetBiocurations: 'getBiocurations',
  GetPreparationType: 'getPreparationType',
  GetMaterialTypes: 'getMaterialTypes',
  GetLabel: 'GetLabel',
  GetTaxonDeterminations: 'GetTaxonDeterminations',
  GetNamespaceSelected: 'getNamespaceSelected'
}

const GetterFunctions = {
  [GetterNames.IsSaving]: isSaving,
  [GetterNames.GetLocked]: getLocked,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetTaxonDetermination]: getTaxonDetermination,
  [GetterNames.GetCollectionEventLabel]: getCollectionEventLabel,
  [GetterNames.GetCollectionEvent]: getCollectionEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetTypeMaterial]: getTypeMaterial,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetIdentifier]: getIdentifier,
  [GetterNames.GetIdentifiers]: getIdentifiers,
  [GetterNames.GetContainer]: getContainer,
  [GetterNames.GetContainerItems]: getContainerItems,
  [GetterNames.GetCollectionObjectTypes]: getCollectionObjectTypes,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetBiocurations]: getBiocurations,
  [GetterNames.GetPreparationType]: getPreparationType,
  [GetterNames.GetMaterialTypes]: getMaterialTypes,
  [GetterNames.GetLabel]: getLabel,
  [GetterNames.GetTaxonDeterminations]: getTaxonDeterminations,
  [GetterNames.GetNamespaceSelected]: getNamespaceSelected
}

export {
  GetterNames,
  GetterFunctions
}
