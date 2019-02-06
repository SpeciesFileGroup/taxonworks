import getLicense from './getLicense'
import getImagesCreated from './getImagesCreated'
import getPeople from './getPeople'
import getYearCopyright from './getYearCopyright'
import getObjectsForDepictions from './getObjectsForDepictions'
import getAttributions from './getAttributions'
import getSettings from './getSettings'

const GetterNames = {
  GetLicense: 'getLicense',
  GetImagesCreated: 'getImagesCreated',
  GetPeople: 'getPeople',
  GetYearCopyright: 'getYearCopyright',
  GetObjectsForDepictions: 'getObjectsForDepictions',
  GetAttributions: 'getAttributions',
  GetSettings: 'getSettings'
}

const GetterFunctions = {
  [GetterNames.GetLicense]: getLicense,
  [GetterNames.GetImagesCreated]: getImagesCreated,
  [GetterNames.GetPeople]: getPeople,
  [GetterNames.GetYearCopyright]: getYearCopyright,
  [GetterNames.GetObjectsForDepictions]: getObjectsForDepictions,
  [GetterNames.GetAttributions]: getAttributions,
  [GetterNames.GetSettings]: getSettings
}

export {
  GetterNames,
  GetterFunctions
}
