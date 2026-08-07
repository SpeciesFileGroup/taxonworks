import getDataset from './getDataset'
import getDatasetRecords from './getDatasetRecords'
import getPagination from './getPagination'
import getParamsFilter from './getParamsFilter'
import getSelectedRowIds from './getSelectedRowIds'
import getRowPositionById from './getRowPositionById'
import getSettings from './getSettings'
import getVirtualPages from './getVirtualPages'
import getCurrentVirtualPage from './getCurrentVirtualPage'
import getNamespaceFor from './getNamespaceFor'
import getCollectionCodeNamespaces from './getCollectionCodeNamespaces'
import getDefaultCollectionCodeNamespaces from './getDefaultCollectionCodeNamespaces'
import getCurrentRowIndex from './getCurrentRowIndex.js'

const GetterNames = {
  GetCollectionCodeNamespaces: 'getCollectionCodeNamespaces',
  GetDataset: 'getDataset',
  GetDefaultCollectionCodeNamespaces: 'getDefaultCollectionCodeNamespaces',
  GetPagination: 'getPagination',
  GetParamsFilter: 'getParamsFilter',
  GetSelectedRowIds: 'getSelectedRowIds',
  GetDatasetRecords: 'getDatasetRecords',
  GetNamespaceFor: 'getNamespaceFor',
  GetRowPositionById: 'getRowPositionById',
  GetSettings: 'getSettings',
  GetVirtualPages: 'getVirtualPages',
  GetCurrentVirtualPage: 'getCurrentVirtualPage',
  GetCurrentRowIndex: 'getCurrentRowIndex'
}

const GetterFunctions = {
  [GetterNames.GetCollectionCodeNamespaces]: getCollectionCodeNamespaces,
  [GetterNames.GetDataset]: getDataset,
  [GetterNames.GetDefaultCollectionCodeNamespaces]:
    getDefaultCollectionCodeNamespaces,
  [GetterNames.GetPagination]: getPagination,
  [GetterNames.GetParamsFilter]: getParamsFilter,
  [GetterNames.GetSelectedRowIds]: getSelectedRowIds,
  [GetterNames.GetDatasetRecords]: getDatasetRecords,
  [GetterNames.GetNamespaceFor]: getNamespaceFor,
  [GetterNames.GetRowPositionById]: getRowPositionById,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetVirtualPages]: getVirtualPages,
  [GetterNames.GetCurrentVirtualPage]: getCurrentVirtualPage,
  [GetterNames.GetCurrentRowIndex]: getCurrentRowIndex
}

export { GetterNames, GetterFunctions }
