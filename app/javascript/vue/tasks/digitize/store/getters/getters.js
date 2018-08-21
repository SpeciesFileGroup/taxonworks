import getCollectionEvent from './getCollectionEvent'
import getCollectionObject from './getCollectionObject'
import getCollectionObjects from './getCollectionObjects'
import getCollectionEventLabel from './getCollectionEventLabel'
import getTypeMaterial from './getTypeMaterial'
import getDepictions from './getDepictions'
import getIdentifier from './getIdentifier'
import getTaxonDetermination from './getTaxonDetermination'

const GetterNames = {
  GetTaxonDetermination: 'getTaxonDetermination',
  GetCollectionEvent: 'getCollectionEvent',
  GetCollectionObject: 'getCollectionObject',
  GetCollectionObjects: 'getCollectionObjects',
  GetCollectionEventLabel: 'getCollectionEventLabel',
  GetTypeMaterial: 'getTypeMaterial',
  GetDepictions: 'getDepictions',
  GetIdentifier: 'getIdentifier'
}

const GetterFunctions = {
  [GetterNames.GetTaxonDetermination]: getTaxonDetermination,
  [GetterNames.GetCollectionEventLabel]: getCollectionEventLabel,
  [GetterNames.GetCollectionEvent]: getCollectionEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetTypeMaterial]: getTypeMaterial,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetIdentifier]: getIdentifier
}

export {
  GetterNames,
  GetterFunctions
}
