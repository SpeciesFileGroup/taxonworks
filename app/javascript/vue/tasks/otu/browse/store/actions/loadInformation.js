import ActionNames from './actionNames'

export default ({ dispatch, state, commit }, otuId) => {
  dispatch(ActionNames.LoadCollectionObjects, otuId)
  dispatch(ActionNames.LoadCollectingEvents, otuId)
  dispatch(ActionNames.LoadPreferences)
}
