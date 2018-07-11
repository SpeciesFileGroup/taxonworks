import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, rejected) => {
    dispatch(ActionNames.SaveCollectionObject).then(respone => {
      dispatch(ActionNames.SaveIdentifier)
    })
  }, (response) => {
    return rejected(response)
  })
}