import setObservation from './setObservation'
import setObservationMatrix from './setObservationMatrix'
import setObservations from './setObservations'
import setRowObjectUnsaved from './setRowObjectUnsaved'

const MutationNames = {
  SetObservation: 'setObservation',
  SetObservations: 'setObservations',
  SetObservationMatrix: 'setObservationMatrix',
  SetRowObjectUnsaved: 'setRowObjectUnsaved'
}

const MutationFunctions = {
  [MutationNames.SetObservation]: setObservation,
  [MutationNames.SetObservations]: setObservations,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetRowObjectUnsaved]: setRowObjectUnsaved
}

export {
  MutationFunctions,
  MutationNames
}
