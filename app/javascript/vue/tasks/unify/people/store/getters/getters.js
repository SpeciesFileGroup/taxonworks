import getFoundPeopleList from './getFoundPeopleList.js'
import getMatchPeople from './getMatchPeople.js'
import getMergePeople from './getMergePeople.js'
import getRequestState from './getRequestState.js'
import getSelectedPerson from './getSelectedPerson.js'
import getSettings from './getSettings.js'
import getURLRequest from './getURLRequest.js'

const GetterNames = {
  GetFoundPeopleList: 'getFoundPeopleList',
  GetMatchPeople: 'getMatchPeople',
  GetMergePeople: 'getMergePeople',
  GetRequestState: 'getRequestState',
  GetSelectedPerson: 'getSelectedPerson',
  GetSettings: 'getSettings',
  GetURLRequest: 'getURLRequest'
}

const GetterFunctions = {
  [GetterNames.GetFoundPeopleList]: getFoundPeopleList,
  [GetterNames.GetMatchPeople]: getMatchPeople,
  [GetterNames.GetMergePeople]: getMergePeople,
  [GetterNames.GetRequestState]: getRequestState,
  [GetterNames.GetSelectedPerson]: getSelectedPerson,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetURLRequest]: getURLRequest
}

export {
  GetterNames,
  GetterFunctions
}
