export default function(response) {
  return {
    paginationPage: Number(response.headers['pagination-page'][0]),
    nextPage: Number(response.headers['pagination-next-page'] ? response.headers['pagination-next-page'][0] : response.headers['pagination-total-pages'][0]),
    previousPage: Number(response.headers['pagination-previous-page'] ? response.headers['pagination-previous-page'][0] : 1),
    perPage: Number(response.headers['pagination-per-page'][0]),
    total: Number(response.headers['pagination-total'][0]),
    totalPages: Number(response.headers['pagination-total-pages'][0])
  }
}