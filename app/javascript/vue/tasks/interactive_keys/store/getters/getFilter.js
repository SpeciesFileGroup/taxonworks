export default state => {
  const filterDescriptors = Object.entries(state.descriptorsFilter).filter(d => d[1] && (!Array.isArray(d[1]) || d[1].length)).map(descriptor => descriptor.map(item => Array.isArray(item) ? item.join('|') : item).join(':')).join('||') || undefined
  const filterRows = Object.values(state.row_filter).join('|')
  return Object.assign({}, { selected_descriptors: filterDescriptors, row_filter: state.settings.rowFilter ? filterRows : [] }, state.filters)
}
