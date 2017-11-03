import ActionNames from './actionNames';
import loadLoan from './loadLoan';
import loadLoanItems from './loadLoanItems';

const ActionFunctions = {
    [ActionNames.LoadLoan]: loadLoan,
    [ActionNames.LoadLoanItems]: loadLoanItems,
};

export { ActionNames, ActionFunctions };