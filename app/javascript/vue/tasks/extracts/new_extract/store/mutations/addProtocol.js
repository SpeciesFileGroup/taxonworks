import Vue from 'vue'

export default (state, protocol) => {
  const index = state.protocol.findIndex(i => i.protocol_id === protocol.protocol_id)

  if (index > -1) {
    Vue.set(state.protocols, index, protocol)
  } else {
    state.protocols.push(protocol)
  }
}
