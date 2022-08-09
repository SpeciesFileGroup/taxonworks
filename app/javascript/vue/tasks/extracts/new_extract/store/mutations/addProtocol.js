export default (state, protocol) => {
  const index = state.protocols.findIndex(i => i.protocol_id === protocol.protocol_id)

  if (index > -1) {
    state.protocols[index] = protocol
  } else {
    state.protocols.push(protocol)
  }

  state.lastChange = Date.now()
}
