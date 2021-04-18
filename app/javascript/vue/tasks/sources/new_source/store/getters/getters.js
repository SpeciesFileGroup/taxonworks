import getBibtexType from './getBibtexType'
import getDocumentations from './getDocumentations'
import getDocuments from './getDocuments'
import getLanguageId from './getLanguageId'
import getLastSave from './getLastSave'
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
  GetDocuments: 'getDocuments',
  GetLanguageId: 'getLanguageId',
  GetLastSave: 'getLastSave',
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
  [GetterNames.GetDocuments]: getDocuments,
  [GetterNames.GetLanguageId]: getLanguageId,
  [GetterNames.GetLastSave]: getLastSave,
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

export {
  GetterNames,
  GetterFunctions
}
