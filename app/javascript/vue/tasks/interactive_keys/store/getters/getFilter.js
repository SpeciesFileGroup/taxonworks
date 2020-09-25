export default state => Object.entries(state.descriptorsFilter).map(descriptor => descriptor.join(':')).join('||')
