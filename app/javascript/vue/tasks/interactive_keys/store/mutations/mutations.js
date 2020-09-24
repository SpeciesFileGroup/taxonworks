import setObservationMatrix from './setObservationMatrix'
import setObservationMatrixDescriptors from './setObservationMatrixDescriptors'
import setSettings from './setSettings'
import setDescriptorsFilter from './setDescriptorsFilter'

const MutationNames = {
  SetDescriptorsFilter: 'setDescriptorsFilter',
  SetObservationMatrix: 'setObsrvationMatrix',
  SetObservationMatrixDescriptors: 'setObservationMatrixDescriptors',
  SetSettings: 'setSettings'
}

const MutationFunctions = {
  [MutationNames.SetDescriptorsFilter]: setDescriptorsFilter,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetObservationMatrixDescriptors]: setObservationMatrixDescriptors,
  [MutationNames.SetSettings]: setSettings
}

export {
  MutationNames,
  MutationFunctions
}
