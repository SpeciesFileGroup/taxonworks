export default function ({ commit, state }, args) {
  return state.request.removeAllObservationsRow(args)
}