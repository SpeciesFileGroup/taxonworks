export default function(response) {
  return {
    paginationPage: Number(response.headers['pagination-page']),
    nextPage: Number(response.headers['pagination-next-page'] ? response.headers['pagination-next-page'] : response.headers['pagination-total-pages']),
    previousPage: Number(response.headers['pagination-previous-page'] ? response.headers['pagination-previous-page'] : 1),
    perPage: Number(response.headers['pagination-per-page']),
    total: Number(response.headers['pagination-total']),
    totalPages: Number(response.headers['pagination-total-pages'])
  }
}