import { MutationNames } from '../mutations/mutations';
import { GetTypeMaterial, GetTaxonName } from '../../request/resources';

export default function({ commit, state }, material) {
	commit(MutationNames.SetTypeMaterial, material);
};