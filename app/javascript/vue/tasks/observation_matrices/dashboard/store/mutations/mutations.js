import setRanks from './setRanks'
import setTaxon from './setTaxon'
import setRankTable from './setRankTable'

const MutationNames = {
  SetRanks: 'setRanks',
  SetTaxon: 'setTaxon',
  SetRankTable: 'setRankTable'
}

const MutationFunctions = {
  [MutationNames.SetRanks]: setRanks,
  [MutationNames.SetTaxon]: setTaxon,
  [MutationNames.SetRankTable]: setRankTable
}

export {
  MutationNames,
  MutationFunctions
}
