import { MutationNames } from '../mutations/mutations';
import { getLoan } from '../../request/resources';

export default function({ commit, state }, id) {
	getLoan(id).then( response => {
    	commit(MutationNames.SetLoan, response)
	});
};