import getType from './getType'
import getVerbatim from './getVerbatim'
import getBibtexType from './getBibtexType'

const GetterNames = {
  GetType: 'getType',
  GetVerbatim: 'getVerbatim',
  GetBibtexType: 'getBibtexType'
}

const GetterFunctions = {
  [GetterNames.GetType]: getType,
  [GetterNames.GetVerbatim]: getVerbatim,
  [GetterNames.GetBibtexType]: getBibtexType
}

export {
  GetterNames,
  GetterFunctions
}
