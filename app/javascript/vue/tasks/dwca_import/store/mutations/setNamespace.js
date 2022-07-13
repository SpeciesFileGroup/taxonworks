export default (state, namespace) => {
  state.namespaces = Object.assign(state.namespaces, { [namespace.id]: namespace })
}
