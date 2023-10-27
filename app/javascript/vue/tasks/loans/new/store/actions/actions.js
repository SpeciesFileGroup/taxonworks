import ActionNames from './actionNames'

import createBatchLoad from './createBatchLoad'
import createLoan from './createLoan'
import deleteLoanItem from './deleteLoanItem'
import loadLoan from './loadLoan'
import loadLoanItems from './loadLoanItems'
import updateLoanItem from './updateLoanItem'
import cloneFrom from './cloneFrom'
import updateLoan from './updateLoan'

const ActionFunctions = {
  [ActionNames.CloneFrom]: cloneFrom,
  [ActionNames.CreateLoan]: createLoan,
  [ActionNames.CreateBatchLoad]: createBatchLoad,
  [ActionNames.DeleteLoanItem]: deleteLoanItem,
  [ActionNames.LoadLoan]: loadLoan,
  [ActionNames.LoadLoanItems]: loadLoanItems,
  [ActionNames.UpdateLoanItem]: updateLoanItem,
  [ActionNames.UpdateLoan]: updateLoan
}

export { ActionNames, ActionFunctions }
