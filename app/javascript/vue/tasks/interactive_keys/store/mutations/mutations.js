import setObservationMatrix from './setObservationMatrix'
import setObservationMatrixDescriptors from './setObservationMatrixDescriptors'
import setSettings from './setSettings'
import setDescriptorsFilter from './setDescriptorsFilter'
import setParamsFilter from './setParamsFilter'
import setRowFilter from './setRowFilter'

const MutationNames = {
  SetDescriptorsFilter: 'setDescriptorsFilter',
  SetObservationMatrix: 'setObsrvationMatrix',
  SetObservationMatrixDescriptors: 'setObservationMatrixDescriptors',
  SetSettings: 'setSettings',
  SetParamsFilter: 'setParamsFilter',
  SetRowFilter: 'setRowFilter'
}

const MutationFunctions = {
  [MutationNames.SetDescriptorsFilter]: setDescriptorsFilter,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetObservationMatrixDescriptors]: setObservationMatrixDescriptors,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetParamsFilter]: setParamsFilter,
  [MutationNames.SetRowFilter]: setRowFilter
}

export {
  MutationNames,
  MutationFunctions
}
