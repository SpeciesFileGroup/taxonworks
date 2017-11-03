import ActionNames from './actionNames';
import loadLoan from './loadLoan';

const ActionFunctions = {
    [ActionNames.LoadLoan]: loadLoan,
};

export { ActionNames, ActionFunctions };