import getSledImage from './getSledImage'
import getCollectionObject from './getCollectionObject'
import getIdentifier from './getIdentifier'
import getImage from './getImage'
import getNavigation from './getNavigation'
import getDepiction from './getDepiction'
import getLocks from './getLocks'

const GetterNames = {
  GetSledImage: 'getSledImage',
  GetIdentifier: 'getIdentifier',
  GetCollectionObject: 'getCollectionObject',
  GetImage: 'getImage',
  GetNavigation: 'getNavigation',
  GetDepiction: 'getDepiction',
  GetLocks: 'getLocks'
}

const GetterFunctions = {
  [GetterNames.GetSledImage]: getSledImage,
  [GetterNames.GetIdentifier]: getIdentifier,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetImage]: getImage,
  [GetterNames.GetNavigation]: getNavigation,
  [GetterNames.GetDepiction]: getDepiction,
  [GetterNames.GetLocks]: getLocks
}

export {
  GetterNames,
  GetterFunctions
}
