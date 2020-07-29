import setSelectedRowIds from './setSelectedRowIds'
import setDataset from './setDataset'
import setPagination from './setPagination'
import setParamsFilter from './setParamsFilter'
import setDatasetRecords from './setDatasetRecords'
import setRow from './setRow'

const MutationNames = {
  SetDataset: 'setDataset',
  SetPagination: 'setPagination',
  SetParamsFilter: 'setParamsFilter',
  SetSelectedRowIds: 'setSelectedRowIds',
  SetDatasetRecords: 'setDatasetRecords',
  SetRow: 'setRow'
}

const MutationFunctions = {
  [MutationNames.SetDataset]: setDataset,
  [MutationNames.SetPagination]: setPagination,
  [MutationNames.SetParamsFilter]: setParamsFilter,
  [MutationNames.SetSelectedRowIds]: setSelectedRowIds,
  [MutationNames.SetDatasetRecords]: setDatasetRecords,
  [MutationNames.SetRow]: setRow
}

export {
  MutationNames,
  MutationFunctions
}
