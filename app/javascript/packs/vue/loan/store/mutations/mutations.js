import setLoan from './setLoan';
import setLoanItems from './setLoanItems';

const MutationNames = {
    SetLoan: 'setLoan',
    SetLoanItems: 'setLoanItems'
};

const MutationFunctions = {
    [MutationNames.SetLoan]: setLoan,
    [MutationNames.SetLoanItems]: setLoanItems,
};

export {
    MutationNames,
    MutationFunctions
}