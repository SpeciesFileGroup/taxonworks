import getBibtexType from './getBibtexType'
import getDocumentations from './getDocumentations'
import getLanguageId from './getLanguageId'
import getPreferences from './getPreferences'
import getRoleAttributes from './getRoleAttributes'
import getRoles from './getRoles'
import getSerialId from './getSerialId'
import getSettings from './getSettings'
import getSoftValidation from './getSoftValidation'
import getSource from './getSource'
import getType from './getType'
import getVerbatim from './getVerbatim'

const GetterNames = {
  GetBibtexType: 'getBibtexType',
  GetDocumentations: 'getDocumentations',
  GetLanguageId: 'getLanguageId',
  GetPreferences: 'getPreferences',
  GetRoleAttributes: 'getRoleAttributes',
  GetRoles: 'getRoles',
  GetSerialId: 'getSerialId',
  GetSettings: 'getSettings',
  GetSoftValidation: 'getSoftValidation',
  GetSource: 'getSource',
  GetType: 'getType',
  GetVerbatim: 'getVerbatim'
}

const GetterFunctions = {
  [GetterNames.GetBibtexType]: getBibtexType,
  [GetterNames.GetDocumentations]: getDocumentations,
  [GetterNames.GetLanguageId]: getLanguageId,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetRoleAttributes]: getRoleAttributes,
  [GetterNames.GetRoles]: getRoles,
  [GetterNames.GetSerialId]: getSerialId,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSoftValidation]: getSoftValidation,
  [GetterNames.GetSource]: getSource,
  [GetterNames.GetType]: getType,
  [GetterNames.GetVerbatim]: getVerbatim
}

export { GetterNames, GetterFunctions }
