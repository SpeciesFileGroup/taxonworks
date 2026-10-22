import { ref } from 'vue'
import ajaxCall from '@/helpers/ajaxCall'

// The most sort keys the backend applies (it ignores the rest). The same for
// every filter, so it's shared here rather than passed down from each task.
// Null until the first sortable_columns response: no limit is enforced.
export const maxSortKeys = ref(null)

// @return [Promise<Array>] the backend's sortable column keys for resource,
//   e.g. 'collection_objects'; [] on failure.
export function fetchSortableColumns(resource) {
  return ajaxCall('get', `/queries/${resource}/sortable_columns.json`)
    .then(({ body }) => {
      if (Number.isInteger(body?.max_sort_keys)) {
        maxSortKeys.value = body.max_sort_keys
      }
      return Array.isArray(body?.columns) ? body.columns : []
    })
    .catch(() => [])
}
