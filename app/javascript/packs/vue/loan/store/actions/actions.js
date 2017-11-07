import ActionNames from './actionNames';

import createBatchLoad from './createBatchLoad';
import deleteLoanItem from './deleteLoanItem';
import loadLoan from './loadLoan';
import loadLoanItems from './loadLoanItems';

const ActionFunctions = {
	[ActionNames.CreateBatchLoad]: createBatchLoad,
    [ActionNames.DeleteLoanItem]: deleteLoanItem,
    [ActionNames.LoadLoan]: loadLoan,
    [ActionNames.LoadLoanItems]: loadLoanItems,
};

export { ActionNames, ActionFunctions };