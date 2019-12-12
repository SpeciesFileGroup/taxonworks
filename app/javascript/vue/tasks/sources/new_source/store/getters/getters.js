import getType from './getType'
import getVerbatim from './getVerbatim'
import getBibtexType from './getBibtexType'
import getSource from './getSource'
import getPreferences from './getPreferences'
import getSettings from './getSettings'
import getSoftValidation from './getSoftValidation'
import getRoles from './getRoles'

const GetterNames = {
  GetType: 'getType',
  GetVerbatim: 'getVerbatim',
  GetBibtexType: 'getBibtexType',
  GetSource: 'getSource',
  GetPreferences: 'getPreferences',
  GetSettings: 'getSettings',
  GetSoftValidation: 'getSoftValidation',
  GetRoles: 'getRoles'
}

const GetterFunctions = {
  [GetterNames.GetType]: getType,
  [GetterNames.GetVerbatim]: getVerbatim,
  [GetterNames.GetBibtexType]: getBibtexType,
  [GetterNames.GetSource]: getSource,
  [GetterNames.GetPreferences]: getPreferences,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSoftValidation]: getSoftValidation,
  [GetterNames.GetRoles]: getRoles
}

export {
  GetterNames,
  GetterFunctions
}
