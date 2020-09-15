import setObservationMatrix from './setObservationMatrix'
import setObservationMatrixDescriptors from './setObservationMatrixDescriptors'
import setSettings from './setSettings'

const MutationNames = {
  SetObservationMatrix: 'setObsrvationMatrix',
  SetObservationMatrixDescriptors: 'setObservationMatrixDescriptors',
  SetSettings: 'setSettings'
}

const MutationFunctions = {
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetObservationMatrixDescriptors]: setObservationMatrixDescriptors,
  [MutationNames.SetSettings]: setSettings
}

export {
  MutationNames,
  MutationFunctions
}
