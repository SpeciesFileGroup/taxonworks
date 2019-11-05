import getType from './getType'
import getVerbatim from './getVerbatim'
import getBibtexType from './getBibtexType'
import getSource from './getSource'

const GetterNames = {
  GetType: 'getType',
  GetVerbatim: 'getVerbatim',
  GetBibtexType: 'getBibtexType',
  GetSource: 'getSource'
}

const GetterFunctions = {
  [GetterNames.GetType]: getType,
  [GetterNames.GetVerbatim]: getVerbatim,
  [GetterNames.GetBibtexType]: getBibtexType,
  [GetterNames.GetSource]: getSource
}

export {
  GetterNames,
  GetterFunctions
}
