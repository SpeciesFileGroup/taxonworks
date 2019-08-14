import getLoan from './getLoan'
import getLoanItems from './getLoanItems'
import getEditLoanItems from './getEditLoanItems'
import getSettings from './getSettings'

const GetterNames = {
  GetLoan: 'getLoan',
  GetLoanItems: 'getLoanItems',
  GetEditLoanItems: 'getEditLoanItems',
  GetSettings: 'getSettings'
}

const GetterFunctions = {
  [GetterNames.GetLoan]: getLoan,
  [GetterNames.GetLoanItems]: getLoanItems,
  [GetterNames.GetEditLoanItems]: getEditLoanItems,
  [GetterNames.GetSettings]: getSettings
}

export {
  GetterNames,
  GetterFunctions
}
