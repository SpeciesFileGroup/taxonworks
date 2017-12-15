import getBiologicalId from './getBiologicalId';
import getCitation from './getCitation';
import getRoles from './getRoles';
import getType from './getType';
import getTypeMaterial from './getTypeMaterial';
import getProtonymId from './getProtonymId';
import getSettings from './getSettings';


const GetterNames = {
    GetBiologicalId: 'getBiologicalId',
    GetCitation: 'getCitation',
    GetRoles: 'getRoles',
    GetType: 'getType',
    GetTypeMaterial: 'getTypeMaterial',
    GetProtonymId: 'getProtonymId',
    GetSettings: 'getSettings'
};

const GetterFunctions = {
    [GetterNames.GetBiologicalId]: getBiologicalId,
    [GetterNames.GetCitation]: getCitation,
    [GetterNames.GetRoles]: getRoles,
    [GetterNames.GetType]: getType,
    [GetterNames.GetTypeMaterial]: getTypeMaterial,
    [GetterNames.GetProtonymId]: getProtonymId,
    [GetterNames.GetSettings]: getSettings,
};

export {
    GetterNames,
    GetterFunctions
}