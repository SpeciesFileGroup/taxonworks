import {
  TYPE_MATERIAL,
  COLLECTION_OBJECT,
  GEOREFERENCE,
  FIELD_OCCURRENCE,
  ASSERTED_DISTRIBUTION
} from '@/constants'
import { RouteNames } from '@/routes/routes'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'

const TYPES = {
  [TYPE_MATERIAL]: null,
  [COLLECTION_OBJECT]: RouteNames.BrowseCollectionObject,
  [FIELD_OCCURRENCE]: RouteNames.BrowseFieldOccurrence,
  [ASSERTED_DISTRIBUTION]: null,
  [GEOREFERENCE]: null
}

function getRelevantType(base) {
  const keys = Object.keys(TYPES)
  const types = base.map((b) => b.type)

  types.sort((a, b) => keys.indexOf(a) - keys.indexOf(b))

  return types[0]
}

function getBrowseUrl(item) {
  const url = TYPES[item.type]
  const param = [ID_PARAM_FOR[item.type]]

  return url
    ? `<a href="${url}?${param}=${item.id}">${item.label}</a>`
    : item.label
}

export function setPopupAndIconToFeatures(data) {
  data.forEach((feature) => {
    feature.properties.marker = {
      icon: getRelevantType(feature.properties.base)
    }
    feature.properties.popup = `
      <ul class="no_bullets">
        ${feature.properties.base
          .map(
            (b) => `
            <li>
              ${getBrowseUrl(b)}
            </li>`
          )
          .join('')}
      </ul>`
  })

  return data
}
