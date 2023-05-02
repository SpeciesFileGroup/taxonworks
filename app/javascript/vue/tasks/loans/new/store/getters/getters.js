import getLoan from './getLoan'
import getLoanItems from './getLoanItems'
import getEditLoanItems from './getEditLoanItems'
import getSettings from './getSettings'
import getPagination from './getPagination'

const GetterNames = {
  GetLoan: 'getLoan',
  GetLoanItems: 'getLoanItems',
  GetEditLoanItems: 'getEditLoanItems',
  GetSettings: 'getSettings',
  GetPagination: 'getPagination'
}

const GetterFunctions = {
  [GetterNames.GetLoan]: getLoan,
  [GetterNames.GetLoanItems]: getLoanItems,
  [GetterNames.GetEditLoanItems]: getEditLoanItems,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetPagination]: getPagination
}

export { GetterNames, GetterFunctions }
