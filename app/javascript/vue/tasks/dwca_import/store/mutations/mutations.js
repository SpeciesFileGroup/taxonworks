import setSelectedRowIds from './setSelectedRowIds'
import setImport from './setImport'

const MutationNames = {
  SetSelectedRowIds: 'setSelectedRowIds',
  SetImport: 'setImport'
}

const MutationFunctions = {
  [MutationNames.SetSelectedRowIds]: setSelectedRowIds,
  [MutationNames.SetImport]: setImport
}

export {
  MutationNames,
  MutationFunctions
}