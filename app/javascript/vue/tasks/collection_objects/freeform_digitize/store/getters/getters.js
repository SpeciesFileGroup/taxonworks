import getCollectionObject from './getCollectionObject'
import getDepiction from './getDepiction'
import getIdentifier from './getIdentifier'
import getImage from './getImage'
import getLocks from './getLocks'
import getNavigation from './getNavigation'
import getSVGBoard from './getSVGBoard'
import getSledImage from './getSledImage'

const GetterNames = {
  GetCollectionObject: 'getCollectionObject',
  GetDepiction: 'getDepiction',
  GetIdentifier: 'getIdentifier',
  GetImage: 'getImage',
  GetLocks: 'getLocks',
  GetNavigation: 'getNavigation',
  GetSVGBoard: 'getSVGBoard',
  GetSledImage: 'getSledImage'
}

const GetterFunctions = {
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetDepiction]: getDepiction,
  [GetterNames.GetIdentifier]: getIdentifier,
  [GetterNames.GetImage]: getImage,
  [GetterNames.GetLocks]: getLocks,
  [GetterNames.GetNavigation]: getNavigation,
  [GetterNames.GetSVGBoard]: getSVGBoard,
  [GetterNames.GetSledImage]: getSledImage
}

export {
  GetterNames,
  GetterFunctions
}
