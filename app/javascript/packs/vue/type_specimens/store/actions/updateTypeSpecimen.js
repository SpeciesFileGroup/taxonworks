import { MutationNames } from '../mutations/mutations';
import { UpdateTypeMaterial } from '../../request/resources';

export default function({ commit, state }, data) {
	commit(MutationNames.SetSaving, true);
	UpdateTypeMaterial(data.type_material.id, data).then(response => {
		TW.workbench.alert.create('Type specimen was successfully updated.', 'notice');
		commit(MutationNames.AddTypeMaterial, response);
		commit(MutationNames.SetTypeMaterial, response);
		commit(MutationNames.SetSaving, false);
	})
};