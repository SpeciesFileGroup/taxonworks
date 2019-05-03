export default function(response) {
  return {
    paginationPage: response.headers.map['pagination-page'][0],
    nextPage: response.headers.map['pagination-next-page'][0],
    previousPage: response.headers.map['pagination-previous-page'][0],
    perPage: response.headers.map['pagination-per-page'][0],
    total: response.headers.map['pagination-total'][0],
    totalPages: response.headers.map['pagination-total-pages'][0]
  }
}