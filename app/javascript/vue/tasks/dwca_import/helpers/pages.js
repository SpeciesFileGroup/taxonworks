const createEmptyPages = (pagination) => {
  const perPage = pagination.perPage
  const recordsCount = pagination.total
  const pagesCount = Math.ceil(recordsCount / perPage)
  return Array.from({ length: pagesCount }, (_, i) => {
    return { count: Math.min(perPage, recordsCount - i * perPage), downloaded: false }
  })
}

export {
  createEmptyPages
}
