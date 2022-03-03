import ActionNames from './actionNames'

import importRow from './importRow'
import loadDataset from './loadDataset'
import loadDatasetRecords from './loadDataSetRecords'
import loadNamespaces from './loadNamespaces'
import updateRow from './updateRow'
import processImport from './processImport'
import resetState from './resetState'

const ActionFunctions = {
  [ActionNames.ImportRow]: importRow,
  [ActionNames.LoadDataset]: loadDataset,
  [ActionNames.LoadDatasetRecords]: loadDatasetRecords,
  [ActionNames.LoadNamespaces]: loadNamespaces,
  [ActionNames.UpdateRow]: updateRow,
  [ActionNames.ProcessImport]: processImport,
  [ActionNames.ResetState]: resetState
}

export {
  ActionFunctions,
  ActionNames
}
