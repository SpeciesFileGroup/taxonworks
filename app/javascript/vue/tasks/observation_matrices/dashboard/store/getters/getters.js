import getRanks from './getRanks'
import getTaxon from './getTaxon'
import getRankTable from './getRankTable'

const GetterNames = {
  GetRanks: 'getRanks',
  GetTaxon: 'getTaxon',
  GetRankTable: 'getRankTable'
}

const GetterFunctions = {
  [GetterNames.GetRanks]: getRanks,
  [GetterNames.GetTaxon]: getTaxon,
  [GetterNames.GetRankTable]: getRankTable
}

export {
  GetterNames,
  GetterFunctions
}
