import getFoundPeopleList from './getFoundPeopleList'
import getSelectedPerson from './getSelectedPerson'

const GetterNames = {
  GetFoundPeopleList: 'getFoundPeopleList',
  GetSelectedPerson: 'getSelectedPerson'
}

const GetterFunctions = {
  [GetterNames.GetFoundPeopleList]: getFoundPeopleList,
  [GetterNames.GetSelectedPerson]: getSelectedPerson
}

export {
  GetterNames,
  GetterFunctions
}
