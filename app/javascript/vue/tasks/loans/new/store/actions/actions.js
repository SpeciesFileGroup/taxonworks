import ActionNames from './actionNames'

import createBatchLoad from './createBatchLoad'
import createLoan from './createLoan'
import deleteLoanItem from './deleteLoanItem'
import loadLoan from './loadLoan'
import loadLoanItems from './loadLoanItems'
import updateLoanItem from './updateLoanItem'

const ActionFunctions = {
  [ActionNames.CreateLoan]: createLoan,
  [ActionNames.CreateBatchLoad]: createBatchLoad,
  [ActionNames.DeleteLoanItem]: deleteLoanItem,
  [ActionNames.LoadLoan]: loadLoan,
  [ActionNames.LoadLoanItems]: loadLoanItems,
  [ActionNames.UpdateLoanItem]: updateLoanItem
}

export { ActionNames, ActionFunctions }
