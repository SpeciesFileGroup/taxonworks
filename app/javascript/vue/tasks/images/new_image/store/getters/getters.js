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
import getSource from './getSource'
import getDepiction from './getDepiction'
import getCitations from './getCitations'
import getTags from './getTags'
import getDataAttributes from './getDataAttributes'
import getPixels from './getPixels'

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
  GetTaxonDeterminations: 'getTaxonDeterminations',
  GetSource: 'getSource',
  GetDepiction: 'getDepiction',
  GetCitations: 'getCitations',
  GetTags: 'getTags',
  GetDataAttributes: 'getDataAttributes',
  GetPixels: 'getPixels'
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
  [GetterNames.GetTaxonDeterminations]: getTaxonDeterminations,
  [GetterNames.GetSource]: getSource,
  [GetterNames.GetDepiction]: getDepiction,
  [GetterNames.GetCitations]: getCitations,
  [GetterNames.GetTags]: getTags,
  [GetterNames.GetDataAttributes]: getDataAttributes,
  [GetterNames.GetPixels]: getPixels
}

export {
  GetterNames,
  GetterFunctions
}
