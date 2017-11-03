import getLoan from './getLoan';
import getLoanItems from './getLoanItems';

const GetterNames = {
    GetLoan: 'getLoan',
    GetLoanItems: 'getLoanItems'
};

const GetterFunctions = {
    [GetterNames.GetLoan]: getLoan,
    [GetterNames.GetLoanItems]: getLoanItems
};

export {
    GetterNames,
    GetterFunctions
}