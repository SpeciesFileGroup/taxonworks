export default state => {
  const filterDescriptors = Object.entries(state.descriptorsFilter).filter(d => d[1]).map(descriptor => descriptor.join(':')).join('||') || undefined
  return Object.assign({}, { selected_descriptors: filterDescriptors }, state.filters)
}
