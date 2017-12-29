import { MutationNames } from '../mutations/mutations';
import { CreateTypeMaterial } from '../../request/resources';

export default function({ commit, state }, data) {
	commit(MutationNames.SetSaving, true);
	CreateTypeMaterial(data).then(response => {
		commit(MutationNames.AddTypeMaterial, response);
		commit(MutationNames.SetTypeMaterial, response);
		commit(MutationNames.SetSaving, false);
	})
};