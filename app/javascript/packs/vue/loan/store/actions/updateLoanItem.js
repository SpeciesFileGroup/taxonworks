import { MutationNames } from '../mutations/mutations';
import { updateLoanItem } from '../../request/resources';

export default function({ commit, state }, object) {
	commit(MutationNames.SetSaving, true);
	updateLoanItem(object).then(response => {
		commit(MutationNames.AddLoanItem, response);
		commit(MutationNames.SetSaving, false);
	})
};