import ActionNames from './actionNames'

export default function ({ commit, dispatch, state }) {
  return new Promise((resolve, reject) => {
    let determinations = state.taxon_determinations
    state.taxon_determinations = []

    determinations.forEach((determination => {
      dispatch(ActionNames.SaveDetermination, determination)
    }))

  })
}