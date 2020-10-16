import setObservationMatrix from './setObservationMatrix'
import setObservationMatrixDescriptors from './setObservationMatrixDescriptors'
import setSettings from './setSettings'
import setDescriptorsFilter from './setDescriptorsFilter'
import setParamsFilter from './setParamsFilter'

const MutationNames = {
  SetDescriptorsFilter: 'setDescriptorsFilter',
  SetObservationMatrix: 'setObsrvationMatrix',
  SetObservationMatrixDescriptors: 'setObservationMatrixDescriptors',
  SetSettings: 'setSettings',
  SetParamsFilter: 'setParamsFilter'
}

const MutationFunctions = {
  [MutationNames.SetDescriptorsFilter]: setDescriptorsFilter,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetObservationMatrixDescriptors]: setObservationMatrixDescriptors,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetParamsFilter]: setParamsFilter
}

export {
  MutationNames,
  MutationFunctions
}
