import getCollectionEvent from './getCollectionEvent'
import getCollectionObject from './getCollectionObject'
import getCollectionObjects from './getCollectionObjects'
import getCollectionEventLabel from './getCollectionEventLabel'
import getTypeMaterial from './getTypeMaterial'
import getDepictions from './getDepictions'
import getIdentifier from './getIdentifier'
import getContainer from './getContainer'
import getContainerItems from './getContainerItems'
import getTaxonDetermination from './getTaxonDetermination'
import getCollectionObjectTypes from './getCollectionObjectTypes'
import getPreferences from './getPreferences'

const GetterNames = {
  GetTaxonDetermination: 'getTaxonDetermination',
  GetCollectionEvent: 'getCollectionEvent',
  GetCollectionObject: 'getCollectionObject',
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectionEventLabel: 'getCollectionEventLabel',
  GetTypeMaterial: 'getTypeMaterial',
  GetDepictions: 'getDepictions',
  GetIdentifier: 'getIdentifier',
  GetContainer: 'getContainer',
  GetContainerItems: 'getContainerItems',
  GetCollectionObjectTypes: 'getCollectionObjectTypes',
  GetPreferences: 'getPreferences'
}

const GetterFunctions = {
  [GetterNames.GetTaxonDetermination]: getTaxonDetermination,
  [GetterNames.GetCollectionEventLabel]: getCollectionEventLabel,
  [GetterNames.GetCollectionEvent]: getCollectionEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetTypeMaterial]: getTypeMaterial,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetIdentifier]: getIdentifier,
  [GetterNames.GetContainer]: getContainer,
  [GetterNames.GetContainerItems]: getContainerItems,
  [GetterNames.GetCollectionObjectTypes]: getCollectionObjectTypes,
  [GetterNames.GetPreferences]: getPreferences
}

export {
  GetterNames,
  GetterFunctions
}
