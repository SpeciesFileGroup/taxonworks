import { MutationNames } from '../mutations/mutations';
import ActionNames from '../actions/actionNames';
import { getLoan, getLoanItems } from '../../request/resources';

export default function({ commit, state, dispatch }, id) {
	getLoan(id).then( response => {
    	commit(MutationNames.SetLoan, response);
    	dispatch(ActionNames.LoadLoanItems, id);
	});
};