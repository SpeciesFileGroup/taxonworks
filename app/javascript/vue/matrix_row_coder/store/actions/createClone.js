export default function ({ commit, state }, args) {
  return state.request.createClone(args)
}
