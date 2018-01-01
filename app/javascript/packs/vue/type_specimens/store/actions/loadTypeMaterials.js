import { MutationNames } from '../mutations/mutations';
import { GetTypeMaterial, GetTaxonName } from '../../request/resources';

export default function({ commit, state }, id) {
	commit(MutationNames.SetLoading, true);
	commit(MutationNames.SetProtonymId, id);
	GetTaxonName(id).then(response => {
		commit(MutationNames.SetTaxon, response);
		GetTypeMaterial(id).then(response => {
			commit(MutationNames.SetTypeMaterials, response);
			commit(MutationNames.SetLoading, false);
		}, () => {
			commit(MutationNames.SetLoading, false);
		})
	}, () => {
		commit(MutationNames.SetLoading, false);
	})
};