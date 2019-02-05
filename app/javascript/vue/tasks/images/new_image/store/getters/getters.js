import getLicense from './getLicense'
import getImagesCreated from './getImagesCreated'

const GetterNames = {
  GetLicense: 'getLicense',
  GetImagesCreated: 'getImagesCreated'
}

const GetterFunctions = {
  [GetterNames.GetLicense]: getLicense,
  [GetterNames.GetImagesCreated]: getImagesCreated
}

export {
  GetterNames,
  GetterFunctions
}
