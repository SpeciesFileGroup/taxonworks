import { computed, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { LinkerStorage } from '@/shared/Filter/utils'
import qs from 'qs'

// The task can be handed two independent scopes, so unlike the shared useQueryParam
// composable (which expects exactly one nested query) both are read here:
//
//   otu_query        - narrows which OTUs are listed
//   taxon_name_query - narrows the pool of TaxonNames matches are drawn from
export function useScopeQueries() {
  const parameters = {
    ...qs.parse(window.location.search, {
      ignoreQueryPrefix: true,
      arrayLimit: 2000
    }),
    ...LinkerStorage.getParameters()
  }

  LinkerStorage.removeParameters()

  const otuQuery = ref(parameters.otu_query || null)
  const taxonNameQuery = ref(parameters.taxon_name_query || null)

  const otuFilterUrl = computed(() => filterUrl(RouteNames.FilterOtus, otuQuery.value))
  const taxonNameFilterUrl = computed(() =>
    filterUrl(RouteNames.FilterTaxonNames, taxonNameQuery.value)
  )

  return {
    otuQuery,
    taxonNameQuery,
    otuFilterUrl,
    taxonNameFilterUrl
  }
}

function filterUrl(route, query) {
  if (!query) return null
  return `${route}?${qs.stringify(query, { arrayFormat: 'brackets' })}`
}
