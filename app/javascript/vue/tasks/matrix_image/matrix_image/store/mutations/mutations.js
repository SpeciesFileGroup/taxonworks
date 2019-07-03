import setMatrix from './setMatrix'
import setObservations from './setObservations'
import setObservationColumns from './setObservationColumns'
import setObservationRows from './setObservationRows'
import setObservationMoved from './setObservationMoved'
import setIsSaving from './setIsSaving'
import setDepictionMoved from './setDepictionMoved'

const MutationNames = {
  SetMatrix: 'setMatrix',
  SetObservations: 'setObservations',
  SetObservationColumns: 'setObservationColumns',
  SetObservationRows: 'setObservationRows',
  SetObservationMoved: 'setObservationMoved',
  SetIsSaving: 'setIsSaving',
  SetDepictionMoved: 'setDepictionMoved'
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
  [MutationNames.SetObservations]: setObservations,
  [MutationNames.SetObservationColumns]: setObservationColumns,
  [MutationNames.SetObservationRows]: setObservationRows,
  [MutationNames.SetObservationMoved]: setObservationMoved,
  [MutationNames.SetIsSaving]: setIsSaving,
  [MutationNames.SetDepictionMoved]: setDepictionMoved
}

export {
  MutationNames,
  MutationFunctions
}