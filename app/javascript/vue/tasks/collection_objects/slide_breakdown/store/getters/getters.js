import getSledImage from './getSledImage'
import getCollectionObject from './getCollectionObject'
import getIdentifier from './getIdentifier'
import getImage from './getImage'

const GetterNames = {
  GetSledImage: 'getSledImage',
  GetIdentifier: 'getIdentifier',
  GetCollectionObject: 'getCollectionObject',
  GetImage: 'getImage'
}

const GetterFunctions = {
  [GetterNames.GetSledImage]: getSledImage,
  [GetterNames.GetIdentifier]: getIdentifier,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetImage]: getImage
}

export {
  GetterNames,
  GetterFunctions
}
