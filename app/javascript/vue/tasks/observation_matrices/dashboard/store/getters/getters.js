import getRanks from './getRanks'
import getTaxon from './getTaxon'

const GetterNames = {
  GetRanks: 'getRanks',
  GetTaxon: 'getTaxon'
}

const GetterFunctions = {
  [GetterNames.GetRanks]: getRanks,
  [GetterNames.GetTaxon]: getTaxon
}

export {
  GetterNames,
  GetterFunctions
}
