
export default state => {
  if (!state.pagination) return []
  const totalPages = Math.ceil(state.pagination.total / state.maxRecordsPerVirtualPage)
  const pages = {}
  if (totalPages > 0) {
    for (let i = 0; i < totalPages; i++) {
      const from = ((i * state.maxRecordsPerVirtualPage) / state.pagination.perPage)
      const to = state.pagination.totalPages > ((i + 1) * (state.maxRecordsPerVirtualPage / state.pagination.perPage)) ? ((i + 1) * (state.maxRecordsPerVirtualPage / state.pagination.perPage)) : state.pagination.totalPages

      pages[(i + 1)] = {
        from: from + 1,
        to: to,
        totalPages: to - from,
        perPage: state.paramsFilter.per,
        total: (to - from) * state.paramsFilter.per
      }
    }
  } else {
    pages[1] = state.pagination
  }
  return pages
}
