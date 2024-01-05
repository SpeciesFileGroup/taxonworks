import resetState from './resetState.js'

const MutationNames = {
  ResetState: 'resetState'
}

const MutationFunctions = {
  [MutationNames.ResetState]: resetState
}

export { MutationNames, MutationFunctions }
