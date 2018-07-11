import getCollectionEvent from './getCollectionEvent'
import getCollectionObject from './getCollectionObject'
import getCollectionEventLabel from './getCollectionEventLabel'
import getTypeMaterial from './getTypeMaterial'
import getDepictions from './getDepictions'
import getIdentifier from './getIdentifier'

const GetterNames = {
  GetCollectionEvent: 'getCollectionEvent',
  GetCollectionObject: 'getCollectionObject',
  GetCollectionEventLabel: 'getCollectionEventLabel',
  GetTypeMaterial: 'getTypeMaterial',
  GetDepictions: 'getDepictions',
  GetIdentifier: 'getIdentifier'
}

const GetterFunctions = {
  [GetterNames.GetCollectionEventLabel]: getCollectionEventLabel,
  [GetterNames.GetCollectionEvent]: getCollectionEvent,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetTypeMaterial]: getTypeMaterial,
  [GetterNames.GetDepictions]: getDepictions,
  [GetterNames.GetIdentifier]: getIdentifier
}

export {
  GetterNames,
  GetterFunctions
}
