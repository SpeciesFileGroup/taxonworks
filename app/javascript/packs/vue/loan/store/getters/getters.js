import getLoan from './getLoan';

const GetterNames = {
    GetLoan: 'getLoan'
};

const GetterFunctions = {
    [GetterNames.GetLoan]: getLoan
};

export {
    GetterNames,
    GetterFunctions
}