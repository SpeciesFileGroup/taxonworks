import ActionNames from './actionNames';

import deleteLoanItem from './deleteLoanItem';
import loadLoan from './loadLoan';
import loadLoanItems from './loadLoanItems';

const ActionFunctions = {
    [ActionNames.DeleteLoanItem]: deleteLoanItem,
    [ActionNames.LoadLoan]: loadLoan,
    [ActionNames.LoadLoanItems]: loadLoanItems,
};

export { ActionNames, ActionFunctions };