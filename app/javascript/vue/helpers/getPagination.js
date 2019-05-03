export default function(response) {
  return {
    paginationPage: Number(response.headers.map['pagination-page'][0]),
    nextPage: Number(response.headers.map['pagination-next-page'][0]),
    previousPage: Number(response.headers.map['pagination-previous-page'][0]),
    perPage: Number(response.headers.map['pagination-per-page'][0]),
    total: Number(response.headers.map['pagination-total'][0]),
    totalPages: Number(response.headers.map['pagination-total-pages'][0])
  }
}