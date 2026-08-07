import resetState from './resetState.js'
import addIdentifier from './addIdentifier.js'

const MutationNames = {
  AddIdentifier: 'addIdentifier',
  ResetState: 'resetState'
}

const MutationFunctions = {
  [MutationNames.AddIdentifier]: addIdentifier,
  [MutationNames.ResetState]: resetState
}

export { MutationNames, MutationFunctions }
