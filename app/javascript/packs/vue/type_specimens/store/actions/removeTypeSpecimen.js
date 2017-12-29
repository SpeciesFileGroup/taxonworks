import { MutationNames } from '../mutations/mutations';
import { DestroyTypeMaterial } from '../../request/resources';

export default function({ commit, state }, id) {
	commit(MutationNames.SetSaving, true);
	DestroyTypeMaterial(id).then(response => {
		commit(MutationNames.RemoveTypeMaterial, id);
		commit(MutationNames.SetSaving, false);
	})
};