import getType from './getType'
import getVerbatim from './getVerbatim'
import getBibtexType from './getBibtexType'
import getSource from './getSource'
import getPreferences from './getPreferences'

const GetterNames = {
  GetType: 'getType',
  GetVerbatim: 'getVerbatim',
  GetBibtexType: 'getBibtexType',
  GetSource: 'getSource',
  GetPreferences: 'getPreferences'
}

const GetterFunctions = {
  [GetterNames.GetType]: getType,
  [GetterNames.GetVerbatim]: getVerbatim,
  [GetterNames.GetBibtexType]: getBibtexType,
  [GetterNames.GetSource]: getSource,
  [GetterNames.GetPreferences]: getPreferences
}

export {
  GetterNames,
  GetterFunctions
}
