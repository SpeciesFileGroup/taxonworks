import { MutationNames } from '../mutations/mutations';
import { GetTypeMaterial } from '../../request/resources';

export default function({ commit, state }, id) {
	commit(MutationNames.SetLoading, true);
	commit(MutationNames.SetProtonymId, id);
	GetTypeMaterial(id).then(response => {
		commit(MutationNames.SetTypeMaterials, response);
		commit(MutationNames.SetLoading, false);
	})
};