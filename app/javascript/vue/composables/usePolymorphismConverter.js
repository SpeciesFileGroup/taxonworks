// The prototypical use: Browse OTU (among others) has a 'Browse AD' navigator
// link which sends an `otu_id=1` query param to the Browse AD task. ADs are
// polymorhpic on object type, so instead of working with multiple query param
// *_id keys internally in Browse AD, this composable converts them all to the
// form
// `asserted_distribution_object_id=1&asserted_distribution_object_type='*'`
import { getParametersFromSession } from "@/shared/Filter/utils"
import { STORAGE_FILTER_QUERY_STATE_PARAMETER } from "@/constants"
import qs from 'qs'

// @param polymorphismBase like, e.g., 'asserted_distribution_object' (the base
//   of 'asserted_distribution_object_id and asserted_distribution_object_type)
// @param polymorphismTypes allowed type data of, e.g.,
//   asserted_distribution_object_type. See
// app/javascript/vue/components/ui/SmartSelector/PolymorphicObjectPicker/PolymorphismClasses
export function usePolymorphicConverter(polymorphismBase, polymorphismTypes) {
  // Like 'otu_id', etc.
  const typeQueryKeys = polymorphismTypes.map((t) => t.query_key)

  // Compare with useFilter.js
  const {
    [STORAGE_FILTER_QUERY_STATE_PARAMETER]: stateId,
    ...urlParameters
  } = qs.parse(location.search, { ignoreQueryPrefix: true })

  Object.assign(urlParameters, getParametersFromSession(stateId))

  for (const param of Object.keys(urlParameters)) {
    const i = typeQueryKeys.indexOf(param)
    if (i != -1) {
      urlParameters[`${polymorphismBase}_id`] = urlParameters[param]
      urlParameters[`${polymorphismBase}_type`] =
        polymorphismTypes[i]['singular']

      delete urlParameters[param]
    }
  }

  const urlParams = qs.stringify(urlParameters, { arrayFormat: 'brackets' })
  history.replaceState(null, null, `${window.location.pathname}?${urlParams}`)
}
