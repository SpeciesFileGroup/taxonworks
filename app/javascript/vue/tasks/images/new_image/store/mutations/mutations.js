import setLicense from './setLicense'

const MutationNames = {
  SetLicense: 'setLicense'
}

const MutationFunctions = {
  [MutationNames.SetLicense]: setLicense
}

export {
  MutationNames,
  MutationFunctions
}
