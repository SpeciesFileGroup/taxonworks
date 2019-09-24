import getRanks from './getRanks'
import getTaxon from './getTaxon'
import getRankTable from './getRankTable'
import getCombinations from './getCombinations'

const GetterNames = {
  GetRanks: 'getRanks',
  GetTaxon: 'getTaxon',
  GetRankTable: 'getRankTable',
  GetCombinations: 'getCombinations'
}

const GetterFunctions = {
  [GetterNames.GetRanks]: getRanks,
  [GetterNames.GetTaxon]: getTaxon,
  [GetterNames.GetRankTable]: getRankTable,
  [GetterNames.GetCombinations]: getCombinations
}

export {
  GetterNames,
  GetterFunctions
}
