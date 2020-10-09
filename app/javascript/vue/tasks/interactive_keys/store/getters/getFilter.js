export default state => {
  const filterDescriptors = Object.entries(state.descriptorsFilter).filter(d => d[1] && d[1].length).map(descriptor => descriptor.map(item => Array.isArray(item) ? item.join('|') : item).join(':')).join('||') || undefined
  return Object.assign({}, { selected_descriptors: filterDescriptors }, state.filters)
}
