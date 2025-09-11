import setObservationMatrix from './setObservationMatrix'
import setObservationMatrixDescriptors from './setObservationMatrixDescriptors'
import setSettings from './setSettings'
import setDescriptorsFilter from './setDescriptorsFilter'
import setParamsFilter from './setParamsFilter'
import setRowFilter from './setRowFilter'
import setLeadId from './setLeadId'

const MutationNames = {
  SetDescriptorsFilter: 'setDescriptorsFilter',
  SetObservationMatrix: 'setObsrvationMatrix',
  SetObservationMatrixDescriptors: 'setObservationMatrixDescriptors',
  SetSettings: 'setSettings',
  SetParamsFilter: 'setParamsFilter',
  SetRowFilter: 'setRowFilter',
  SetLeadId: 'setLeadId'
}

const MutationFunctions = {
  [MutationNames.SetDescriptorsFilter]: setDescriptorsFilter,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetObservationMatrixDescriptors]: setObservationMatrixDescriptors,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetParamsFilter]: setParamsFilter,
  [MutationNames.SetRowFilter]: setRowFilter,
  [MutationNames.SetLeadId]: setLeadId
}

export {
  MutationNames,
  MutationFunctions
}
