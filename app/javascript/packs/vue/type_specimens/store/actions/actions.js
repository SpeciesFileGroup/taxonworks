import ActionNames from './actionNames';
import loadTypeMaterials from './loadTypeMaterials';
import createTypeMaterial from './createTypeMaterial';
import removeTypeSpecimen from './removeTypeSpecimen';

const ActionFunctions = {
	[ActionNames.LoadTypeMaterials]: loadTypeMaterials,
	[ActionNames.CreateTypeMaterial]: createTypeMaterial,
	[ActionNames.RemoveTypeSpecimen]: removeTypeSpecimen
};

export { ActionNames, ActionFunctions };