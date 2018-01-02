import { MutationNames } from '../mutations/mutations';
import { DestroyTypeMaterial } from '../../request/resources';

export default function({ commit, state }, id) {
	commit(MutationNames.SetSaving, true);
	DestroyTypeMaterial(id).then(response => {
		TW.workbench.alert.create('Type specimen was successfully deleted.', 'notice');
		commit(MutationNames.RemoveTypeMaterial, id);
		commit(MutationNames.SetSaving, false);
	})
};