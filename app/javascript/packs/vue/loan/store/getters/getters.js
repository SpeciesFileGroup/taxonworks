import getLoan from './getLoan';
import getLoanItems from './getLoanItems';
import getSettings from './getSettings';

const GetterNames = {
    GetLoan: 'getLoan',
    GetLoanItems: 'getLoanItems',
    GetSettings: 'getSettings'
};

const GetterFunctions = {
    [GetterNames.GetLoan]: getLoan,
    [GetterNames.GetLoanItems]: getLoanItems,
    [GetterNames.GetSettings]: getSettings
};

export {
    GetterNames,
    GetterFunctions
}