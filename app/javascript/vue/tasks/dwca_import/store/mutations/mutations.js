import setCurrentVirtualPage from './setCurrentVirtualPage'
import setSelectedRowIds from './setSelectedRowIds'
import setDataset from './setDataset'
import setPagination from './setPagination'
import setParamsFilter from './setParamsFilter'
import setDatasetRecords from './setDatasetRecords'
import setRow from './setRow'
import setDatasetPage from './setDatasetPage'
import setSettings from './setSettings'
import setState from './setState'
import setNamespace from './setNamespace'

const MutationNames = {
  SetCurrentVirtualPage: 'setCurrentVirtualPage',
  SetDataset: 'setDataset',
  SetPagination: 'setPagination',
  SetParamsFilter: 'setParamsFilter',
  SetSelectedRowIds: 'setSelectedRowIds',
  SetDatasetRecords: 'setDatasetRecords',
  SetDatasetPage: 'setDatasetPage',
  SetNamespace: 'setNamespace',
  SetRow: 'setRow',
  SetSettings: 'setSettings',
  SetState: 'setState'
}

const MutationFunctions = {
  [MutationNames.SetCurrentVirtualPage]: setCurrentVirtualPage,
  [MutationNames.SetDataset]: setDataset,
  [MutationNames.SetPagination]: setPagination,
  [MutationNames.SetParamsFilter]: setParamsFilter,
  [MutationNames.SetSelectedRowIds]: setSelectedRowIds,
  [MutationNames.SetDatasetRecords]: setDatasetRecords,
  [MutationNames.SetDatasetPage]: setDatasetPage,
  [MutationNames.SetNamespace]: setNamespace,
  [MutationNames.SetRow]: setRow,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetState]: setState
}

export {
  MutationNames,
  MutationFunctions
}
