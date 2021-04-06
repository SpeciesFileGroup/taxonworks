import getSettings from './getSettings'
import getExtract from './getExtract'
import getIdentifiers from './getIdentifiers'
import getSoftValidation from './getSoftValidation'
import getUserPreferences from './getUserPreferences'
import getProjectPreferences from './getProjectPreferences'
import getOriginRelationship from './getOriginRelationship'

const GetterNames = {
  GetExtract: 'getExtract',
  GetIdentifiers: 'getIdentifiers',
  GetSettings: 'getSettings',
  GetSoftValidation: 'getSoftValidation',
  GetUserPreferences: 'getUserPreferences',
  GetProjectPreferences: 'getProjectPreferences',
  GetOriginRelationship: 'getOriginRelationship'
}

const GetterFunctions = {
  [GetterNames.GetExtract]: getExtract,
  [GetterNames.GetIdentifiers]: getIdentifiers,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSoftValidation]: getSoftValidation,
  [GetterNames.GetProjectPreferences]: getProjectPreferences,
  [GetterNames.GetUserPreferences]: getUserPreferences,
  [GetterNames.GetOriginRelationship]: getOriginRelationship
}

export {
  GetterNames,
  GetterFunctions
}
