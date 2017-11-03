import { MutationNames } from '../mutations/mutations';
import { getLoanItems } from '../../request/resources';

export default function({ commit, state }, id) {
	getLoanItems(id).then( response => {
    	commit(MutationNames.SetLoanItems, response)
	});
};