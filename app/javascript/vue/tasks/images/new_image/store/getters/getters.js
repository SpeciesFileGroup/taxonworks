import getAttributions from './getAttributions'
import getCitations from './getCitations'
import getCollectionObject from './getCollectionObject'
import getDataAttributes from './getDataAttributes'
import getDepiction from './getDepiction'
import getImagesCreated from './getImagesCreated'
import getLicense from './getLicense'
import getNewCOForSqed from './getNewCOForSqed'
import getObjectsForDepictions from './getObjectsForDepictions'
import getPeople from './getPeople'
import getPixels from './getPixels'
import getRepository from './getRepository'
import getSettings from './getSettings'
import getSource from './getSource'
import getSqed from './getSqed'
import getTags from './getTags'
import getTaxonDetermination from './getTaxonDetermination'
import getTaxonDeterminations from './getTaxonDeterminations'
import getYearCopyright from './getYearCopyright'

const GetterNames = {
  GetAttributions: 'getAttributions',
  GetCitations: 'getCitations',
  GetCollectionObject: 'getCollectionObject',
  GetDataAttributes: 'getDataAttributes',
  GetDepiction: 'getDepiction',
  GetImagesCreated: 'getImagesCreated',
  GetLicense: 'getLicense',
  GetNewCOForSqed: 'getNewCOForSqed',
  GetObjectsForDepictions: 'getObjectsForDepictions',
  GetPeople: 'getPeople',
  GetPixels: 'getPixels',
  GetRepository: 'getRepository',
  GetSettings: 'getSettings',
  GetSource: 'getSource',
  GetSqed: 'getSqed',
  GetTags: 'getTags',
  GetTaxonDetermination: 'getTaxonDetermination',
  GetTaxonDeterminations: 'getTaxonDeterminations',
  GetYearCopyright: 'getYearCopyright'
}

const GetterFunctions = {
  [GetterNames.GetAttributions]: getAttributions,
  [GetterNames.GetCitations]: getCitations,
  [GetterNames.GetCollectionObject]: getCollectionObject,
  [GetterNames.GetDataAttributes]: getDataAttributes,
  [GetterNames.GetDepiction]: getDepiction,
  [GetterNames.GetImagesCreated]: getImagesCreated,
  [GetterNames.GetLicense]: getLicense,
  [GetterNames.GetNewCOForSqed]: getNewCOForSqed,
  [GetterNames.GetObjectsForDepictions]: getObjectsForDepictions,
  [GetterNames.GetPeople]: getPeople,
  [GetterNames.GetPixels]: getPixels,
  [GetterNames.GetRepository]: getRepository,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSource]: getSource,
  [GetterNames.GetSqed]: getSqed,
  [GetterNames.GetTags]: getTags,
  [GetterNames.GetTaxonDetermination]: getTaxonDetermination,
  [GetterNames.GetTaxonDeterminations]: getTaxonDeterminations,
  [GetterNames.GetYearCopyright]: getYearCopyright
}

export {
  GetterNames,
  GetterFunctions
}
