import setMatrix from './setMatrix'
import setObservations from './setObservations'
import setObservationColumns from './setObservationColumns'
import setObservationRows from './setObservationRows'
import setObservationMoved from './setObservationMoved'

const MutationNames = {
  SetMatrix: 'setMatrix',
  SetObservations: 'setObservations',
  SetObservationColumns: 'setObservationColumns',
  SetObservationRows: 'setObservationRows',
  SetObservationMoved: 'setObservationMoved'
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
  [MutationNames.SetObservations]: setObservations,
  [MutationNames.SetObservationColumns]: setObservationColumns,
  [MutationNames.SetObservationRows]: setObservationRows,
  [MutationNames.SetObservationMoved]: setObservationMoved
}

export {
  MutationNames,
  MutationFunctions
}