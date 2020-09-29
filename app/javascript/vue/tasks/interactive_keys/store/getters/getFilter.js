export default state => Object.entries(state.descriptorsFilter).filter(d => d[1]).map(descriptor => descriptor.join(':')).join('||')
