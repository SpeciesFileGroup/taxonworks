import ActionNames from './actionNames';
import loadTypeMaterial from './loadTypeMaterial';
import loadTypeMaterials from './loadTypeMaterials';
import createTypeMaterial from './createTypeMaterial';
import removeTypeSpecimen from './removeTypeSpecimen';
import updateTypeSpecimen from './updateTypeSpecimen';
import updateCollectionObject from './updateCollectionObject';

const ActionFunctions = {
	[ActionNames.LoadTypeMaterial]: loadTypeMaterial,
	[ActionNames.LoadTypeMaterials]: loadTypeMaterials,
	[ActionNames.CreateTypeMaterial]: createTypeMaterial,
	[ActionNames.RemoveTypeSpecimen]: removeTypeSpecimen,
	[ActionNames.UpdateTypeSpecimen]: updateTypeSpecimen,
	[ActionNames.UpdateCollectionObject]: updateCollectionObject
};

export { ActionNames, ActionFunctions };