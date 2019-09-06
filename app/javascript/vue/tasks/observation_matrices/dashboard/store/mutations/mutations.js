import setRanks from './setRanks'
import setTaxon from './setTaxon'

const MutationNames = {
  SetRanks: 'setRanks',
  SetTaxon: 'setTaxon'
}

const MutationFunctions = {
  [MutationNames.SetRanks]: setRanks,
  [MutationNames.SetTaxon]: setTaxon
}

export {
  MutationNames,
  MutationFunctions
}
