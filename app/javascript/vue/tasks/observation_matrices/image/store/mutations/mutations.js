import addNewColumn from './addNewColumn'
import setObservationMatrix from './setObservationMatrix'
import setObservations from './setObservations'
import setObservationColumns from './setObservationColumns'
import setObservationLanguages from './setObservationLanguages'
import setObservationRows from './setObservationRows'
import setObservationMoved from './setObservationMoved'
import setIsSaving from './setIsSaving'
import setDepictionMoved from './setDepictionMoved'
import setPagination from './setPagination'
import addDepiction from './addDepiction'
import removeDepiction from './removeDepiction'
import removeOtuDepiction from './removeOtuDepiction'

const MutationNames = {
  AddDepiction: 'addDepiction',
  AddNewColumn: 'addNewColumn',
  SetObservationMatrix: 'setObservationMatrix',
  SetObservations: 'setObservations',
  SetObservationColumns: 'setObservationColumns',
  SetObservationLanguages: 'setObservationLanguages',
  SetObservationRows: 'setObservationRows',
  SetObservationMoved: 'setObservationMoved',
  SetIsSaving: 'setIsSaving',
  SetDepictionMoved: 'setDepictionMoved',
  RemoveDepiction: 'removeDepiction',
  RemoveOtuDepiction: 'removeOtuDepiction',
  SetPagination: 'setPagination'
}

const MutationFunctions = {
  [MutationNames.AddDepiction]: addDepiction,
  [MutationNames.AddNewColumn]: addNewColumn,
  [MutationNames.SetObservationMatrix]: setObservationMatrix,
  [MutationNames.SetObservations]: setObservations,
  [MutationNames.SetObservationColumns]: setObservationColumns,
  [MutationNames.SetObservationLanguages]: setObservationLanguages,
  [MutationNames.SetObservationRows]: setObservationRows,
  [MutationNames.SetObservationMoved]: setObservationMoved,
  [MutationNames.SetIsSaving]: setIsSaving,
  [MutationNames.SetDepictionMoved]: setDepictionMoved,
  [MutationNames.SetPagination]: setPagination,
  [MutationNames.RemoveDepiction]: removeDepiction,
  [MutationNames.RemoveOtuDepiction]: removeOtuDepiction
}

export {
  MutationNames,
  MutationFunctions
}
