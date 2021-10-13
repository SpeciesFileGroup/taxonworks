import getDataset from './getDataset'
import getDatasetRecords from './getDatasetRecords'
import getPagination from './getPagination'
import getParamsFilter from './getParamsFilter'
import getSelectedRowIds from './getSelectedRowIds'
import getRowPositionById from './getRowPositionById'
import getSettings from './getSettings'
import getVirtualPages from './getVirtualPages'
import getCurrentVirtualPage from './getCurrentVirtualPage'
import getStartRow from './getStartRow'

const GetterNames = {
  GetDataset: 'getDataset',
  GetPagination: 'getPagination',
  GetParamsFilter: 'getParamsFilter',
  GetSelectedRowIds: 'getSelectedRowIds',
  GetDatasetRecords: 'getDatasetRecords',
  GetRowPositionById: 'getRowPositionById',
  GetSettings: 'getSettings',
  GetVirtualPages: 'getVirtualPages',
  GetCurrentVirtualPage: 'getCurrentVirtualPage',
  getStartRow: 'getStartRow'
}

const GetterFunctions = {
  [GetterNames.GetDataset]: getDataset,
  [GetterNames.GetPagination]: getPagination,
  [GetterNames.GetParamsFilter]: getParamsFilter,
  [GetterNames.GetSelectedRowIds]: getSelectedRowIds,
  [GetterNames.GetDatasetRecords]: getDatasetRecords,
  [GetterNames.GetRowPositionById]: getRowPositionById,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetVirtualPages]: getVirtualPages,
  [GetterNames.GetCurrentVirtualPage]: getCurrentVirtualPage,
  [GetterNames.GetStartRow]: getStartRow,
}

export {
  GetterNames,
  GetterFunctions
}
