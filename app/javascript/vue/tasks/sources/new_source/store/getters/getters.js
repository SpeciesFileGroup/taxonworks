import getType from './getType'
import getVerbatim from './getVerbatim'
import getBibtexType from './getBibtexType'
import getSource from './getSource'
import getPreferences from './getPreferences'
import getSettings from './getSettings'
import getSoftValidation from './getSoftValidation'
import getRoles from './getRoles'
import getLastSave from './getLastSave'
import getSerialId from './getSerialId'
import getLanguageId from './getLanguageId'

const GetterNames = {
  GetType: 'getType',
  GetVerbatim: 'getVerbatim',
  GetBibtexType: 'getBibtexType',
  GetSource: 'getSource',
  GetPreferences: 'getPreferences',
  GetSettings: 'getSettings',
  GetSoftValidation: 'getSoftValidation',
  GetRoles: 'getRoles',
  GetLastSave: 'getLastSave',
  GetSerialId: 'getSerialId',
  GetLanguageId: 'getLanguageId'
}

const GetterFunctions = {
  [GetterNames.GetType]: getType,
  [GetterNames.GetVerbatim]: getVerbatim,
  [GetterNames.GetBibtexType]: getBibtexType,
  [GetterNames.GetSource]: getSource,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSoftValidation]: getSoftValidation,
  [GetterNames.GetRoles]: getRoles,
  [GetterNames.GetLastSave]: getLastSave,
  [GetterNames.GetSerialId]: getSerialId,
  [GetterNames.GetLanguageId]: getLanguageId
}

export {
  GetterNames,
  GetterFunctions
}
