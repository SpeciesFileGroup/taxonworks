import getBiologicalId from './getBiologicalId';
import getCitation from './getCitation';
import getRoles from './getRoles';
import getType from './getType';
import getSettings from './getSettings';


const GetterNames = {
    GetBiologicalId: 'getBiologicalId',
    GetCitation: 'getCitation',
    GetRoles: 'getRoles',
    GetType: 'getType',
    GetSettings: 'getSettings'
};

const GetterFunctions = {
    [GetterNames.GetBiologicalId]: getBiologicalId,
    [GetterNames.GetCitation]: getCitation,
    [GetterNames.GetRoles]: getRoles,
    [GetterNames.GetType]: getType,
    [GetterNames.GetSettings]: getSettings,
};

export {
    GetterNames,
    GetterFunctions
}