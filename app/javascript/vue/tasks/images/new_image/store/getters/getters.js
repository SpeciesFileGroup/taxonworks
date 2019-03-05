import getLicense from './getLicense'
import getImagesCreated from './getImagesCreated'
import getPeople from './getPeople'
import getYearCopyright from './getYearCopyright'
import getObjectsForDepictions from './getObjectsForDepictions'
import getAttributions from './getAttributions'
import getSettings from './getSettings'
import getSqed from './getSqed'
import getNewCOForSqed from './getNewCOForSqed'
import getCollectionObject from './getCollectionObject'
import getTaxonDeterminations from './getTaxonDeterminations'

const GetterNames = {
  GetLicense: 'getLicense',
  GetImagesCreated: 'getImagesCreated',
  GetPeople: 'getPeople',
  GetYearCopyright: 'getYearCopyright',
  GetObjectsForDepictions: 'getObjectsForDepictions',
  GetAttributions: 'getAttributions',
  GetSettings: 'getSettings',
  GetSqed: 'getSqed',
  GetNewCOForSqed: 'getNewCOForSqed',
  GetCollectionObject: 'getCollectionObject',
  GetTaxonDeterminations: 'getTaxonDeterminations'
}

const GetterFunctions = {
  [GetterNames.GetLicense]: getLicense,
  [GetterNames.GetImagesCreated]: getImagesCreated,
  [GetterNames.GetPeople]: getPeople,
  [GetterNames.GetYearCopyright]: getYearCopyright,
  [GetterNames.GetObjectsForDepictions]: getObjectsForDepictions,
  [GetterNames.GetAttributions]: getAttributions,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSqed]: getSqed,
  [GetterNames.GetNewCOForSqed]: getNewCOForSqed,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetTaxonDeterminations]: getTaxonDeterminations
}

export {
  GetterNames,
  GetterFunctions
}
