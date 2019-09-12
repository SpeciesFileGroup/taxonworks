import setRanks from './setRanks'
import setTaxon from './setTaxon'
import setRankTable from './setRankTable'
import setCombinations from './setCombinations'

const MutationNames = {
  SetRanks: 'setRanks',
  SetTaxon: 'setTaxon',
  SetRankTable: 'setRankTable',
  SetCombinations: 'setCombinations'
}

const MutationFunctions = {
  [MutationNames.SetRanks]: setRanks,
  [MutationNames.SetTaxon]: setTaxon,
  [MutationNames.SetRankTable]: setRankTable,
  [MutationNames.SetCombinations]: setCombinations
}

export {
  MutationNames,
  MutationFunctions
}
