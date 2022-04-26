import getRecent from './getRecent'
import getSettings from './getSettings'
import getExtract from './getExtract'
import getIdentifiers from './getIdentifiers'
import getSoftValidation from './getSoftValidation'
import getUserPreferences from './getUserPreferences'
import getProjectPreferences from './getProjectPreferences'
import getOriginRelationship from './getOriginRelationship'
import getRepository from './getRepository'
import getProtocols from './getProtocols'
import getLastSave from './getLastSave'
import getLastChange from './getLastChange'
import getRoles from './getRoles'

const GetterNames = {
  GetRecent: 'getRecent',
  GetExtract: 'getExtract',
  GetIdentifiers: 'getIdentifiers',
  GetSettings: 'getSettings',
  GetSoftValidation: 'getSoftValidation',
  GetUserPreferences: 'getUserPreferences',
  GetProjectPreferences: 'getProjectPreferences',
  GetOriginRelationship: 'getOriginRelationship',
  GetRepository: 'getRepository',
  GetProtocols: 'getProtocols',
  GetLastSave: 'getLastSave',
  GetLastChange: 'getLastChange',
  GetRoles: 'getRoles'
}

const GetterFunctions = {
  [GetterNames.GetRecent]: getRecent,
  [GetterNames.GetExtract]: getExtract,
  [GetterNames.GetIdentifiers]: getIdentifiers,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSoftValidation]: getSoftValidation,
  [GetterNames.GetProjectPreferences]: getProjectPreferences,
  [GetterNames.GetUserPreferences]: getUserPreferences,
  [GetterNames.GetOriginRelationship]: getOriginRelationship,
  [GetterNames.GetRepository]: getRepository,
  [GetterNames.GetProtocols]: getProtocols,
  [GetterNames.GetLastSave]: getLastSave,
  [GetterNames.GetLastChange]: getLastChange,
  [GetterNames.GetRoles]: getRoles
}

export {
  GetterNames,
  GetterFunctions
}
