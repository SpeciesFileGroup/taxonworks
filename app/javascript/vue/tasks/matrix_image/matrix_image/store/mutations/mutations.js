import setMatrix from './setMatrix'
import setObservations from './setObservations'
import setObservationColumns from './setObservationColumns'
import setObservationRows from './setObservationRows'

const MutationNames = {
  SetMatrix: 'setMatrix',
  SetObservations: 'setObservations',
  SetObservationColumns: 'setObservationColumns',
  SetObservationRows: 'setObservationRows',
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
  [MutationNames.SetObservations]: setObservations,
  [MutationNames.SetObservationColumns]: setObservationColumns,
  [MutationNames.SetObservationRows]: setObservationRows,
}

export {
  MutationNames,
  MutationFunctions
}