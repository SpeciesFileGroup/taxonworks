import setSettings from './setSettings'

const MutationNames = {
  SetSettings: 'setSettings'
}

const MutationFunctions = {
  [MutationNames.SetSettings]: setSettings
}

export {
  MutationNames,
  MutationFunctions
}
