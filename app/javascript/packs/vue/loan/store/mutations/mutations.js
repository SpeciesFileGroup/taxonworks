import setLoan from './setLoan';

const MutationNames = {
    SetLoan: 'setLoan',
};

const MutationFunctions = {
    [MutationNames.SetLoan]: setLoan,
};

export {
    MutationNames,
    MutationFunctions
}