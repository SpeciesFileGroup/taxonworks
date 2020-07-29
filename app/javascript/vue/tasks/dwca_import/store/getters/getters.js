import getDataset from './getDataset'
import getDatasetRecords from './getDatasetRecords'
import getPagination from './getPagination'
import getParamsFilter from './getParamsFilter'
import getSelectedRowIds from './getSelectedRowIds'
import getRowPositionById from './getRowPositionById'
import getSettings from './getSettings'

const GetterNames = {
  GetDataset: 'getDataset',
  GetPagination: 'getPagination',
  GetParamsFilter: 'getParamsFilter',
  GetSelectedRowIds: 'getSelectedRowIds',
  GetDatasetRecords: 'getDatasetRecords',
  GetRowPositionById: 'getRowPositionById',
  GetSettings: 'getSettings'
}

const GetterFunctions = {
  [GetterNames.GetDataset]: getDataset,
  [GetterNames.GetPagination]: getPagination,
  [GetterNames.GetParamsFilter]: getParamsFilter,
  [GetterNames.GetSelectedRowIds]: getSelectedRowIds,
  [GetterNames.GetDatasetRecords]: getDatasetRecords,
  [GetterNames.GetRowPositionById]: getRowPositionById,
  [GetterNames.GetSettings]: getSettings
}

export {
  GetterNames,
  GetterFunctions
}
