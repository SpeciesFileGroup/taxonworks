export default state => {
  const filterDescriptors = Object.entries(state.descriptorsFilter)
    .filter(([_, descriptorValue]) => descriptorValue !== undefined && (!Array.isArray(descriptorValue) || descriptorValue.length))
    .map(descriptor => descriptor.map(item => Array.isArray(item) ? item.join('|') : item).join(':')).join('||') || undefined

  const filterRows = Object.values(state.row_filter).join('|')
  return Object.assign({}, { selected_descriptors: filterDescriptors, row_filter: state.settings.rowFilter ? filterRows : [] }, state.filters)
}
