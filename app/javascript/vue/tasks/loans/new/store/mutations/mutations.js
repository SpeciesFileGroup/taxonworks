import setLoan from './setLoan'
import setLoanItems from './setLoanItems'
import addLoanItem from './addLoanItem'
import addEditLoanItem from './addEditLoanItem'
import setLoading from './setLoading'
import setSaving from './setSaving'
import removeLoanItem from './removeLoanItem'
import removeEditLoanItem from './removeEditLoanItem'
import cleanEditLoanItems from './cleanEditLoanItems'
import setAllEditLoanItems from './setAllEditLoanItems'
import setEditLoanItems from './setEditLoanItems'

const MutationNames = {
  AddLoanItem: 'addLoanItem',
  AddEditLoanItem: 'addEditLoanItem',
  CleanEditLoanItems: 'cleanEditLoanItems',
  SetLoan: 'setLoan',
  SetLoanItems: 'setLoanItems',
  SetLoading: 'setLoading',
  SetSaving: 'setSaving',
  SetAllEditLoanItems: 'setAllEditLoanItems',
  SetEditLoanItems: 'setEditLoanItems',
  RemoveLoanItem: 'removeLoanItem',
  RemoveEditLoanItem: 'removeEditLoanItem'
}

const MutationFunctions = {
  [MutationNames.AddLoanItem]: addLoanItem,
  [MutationNames.AddEditLoanItem]: addEditLoanItem,
  [MutationNames.CleanEditLoanItems]: cleanEditLoanItems,
  [MutationNames.SetLoan]: setLoan,
  [MutationNames.SetLoanItems]: setLoanItems,
  [MutationNames.SetLoading]: setLoading,
  [MutationNames.SetSaving]: setSaving,
  [MutationNames.SetAllEditLoanItems]: setAllEditLoanItems,
  [MutationNames.SetEditLoanItems]: setEditLoanItems,
  [MutationNames.RemoveLoanItem]: removeLoanItem,
  [MutationNames.RemoveEditLoanItem]: removeEditLoanItem
}

export {
  MutationNames,
  MutationFunctions
}
