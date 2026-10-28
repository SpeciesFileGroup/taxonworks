import { Query } from '@/routes/endpoints'

// @return [Promise<Object|null>] the backend's sort keys for resource, e.g.
//   'collection_objects', as { columns, maxSortKeys }; null when the request
//   fails, so callers keep sorting ungated rather than treating "unknown" as
//   "nothing is sortable".
export function fetchSortableColumns(resource) {
  return Query.sortableColumns(resource)
    .then(({ body }) => ({
      columns: Array.isArray(body?.columns) ? body.columns : [],
      maxSortKeys: Number.isInteger(body?.max_sort_keys)
        ? body.max_sort_keys
        : null
    }))
    .catch(() => null)
}
