import getLicense from './getLicense'
import getImagesCreated from './getImagesCreated'
import getPeople from './getPeople'

const GetterNames = {
  GetLicense: 'getLicense',
  GetImagesCreated: 'getImagesCreated',
  GetPeople: 'getPeople'
}

const GetterFunctions = {
  [GetterNames.GetLicense]: getLicense,
  [GetterNames.GetImagesCreated]: getImagesCreated,
  [GetterNames.GetPeople]: getPeople
}

export {
  GetterNames,
  GetterFunctions
}
