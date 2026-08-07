import { ref, computed } from 'vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import qs from 'qs'
import {
  Tag,
  Note,
  Confidence,
  DataAttribute,
  Citation,
  Identifier,
  AlternateValue,
  Attribution,
  Depiction,
  Documentation,
  ProjectMember
} from '@/routes/endpoints'
import { ATTRIBUTES_BY_TYPE } from '../constants/attributes.js'

const SERVICES = {
  tags: Tag,
  notes: Note,
  confidences: Confidence,
  data_attributes: DataAttribute,
  citations: Citation,
  identifiers: Identifier,
  alternate_values: AlternateValue,
  attributions: Attribution,
  depictions: Depiction,
  documentation: Documentation
}

function getNestedValue(obj, path) {
  return path.split('.').reduce((acc, key) => acc?.[key], obj)
}

function flattenAttributes(list, attributes) {
  const dotKeys = Object.keys(attributes).filter((k) => k.includes('.'))

  if (!dotKeys.length) return list

  return list.map((item) => {
    const flat = { ...item }

    for (const key of dotKeys) {
      if (!(key in flat)) {
        flat[key] = getNestedValue(item, key)
      }
    }

    return flat
  })
}

export default function useAnnotationFilter() {
  const annotationType = ref(null)
  const annotationTypes = ref({})
  const currentService = ref(null)
  const membersMap = ref({})

  const urlParams = qs.parse(location.search, { ignoreQueryPrefix: true })

  if (urlParams.annotation_type && SERVICES[urlParams.annotation_type]) {
    annotationType.value = urlParams.annotation_type
    currentService.value = SERVICES[urlParams.annotation_type]
  }

  const membersPromise = ProjectMember.all().then(({ body }) => {
    const map = {}

    for (const member of body) {
      map[member.user.id] = member.user.name
    }

    membersMap.value = map
  })

  const serviceProxy = {
    filter: (params) => {
      if (!currentService.value) {
        return Promise.reject(new Error('No annotation type selected'))
      }

      const translatedParams = translateParameters(params)

      return currentService.value.filter(translatedParams)
    }
  }

  const listParser = async (list) => {
    await membersPromise

    const attrs = annotationType.value
      ? ATTRIBUTES_BY_TYPE[annotationType.value] || {}
      : {}

    const flattened = flattenAttributes(list, attrs)

    return flattened.map((item) => ({
      ...item,
      created_by: membersMap.value[item.created_by_id] || ''
    }))
  }

  const filterState = useFilter(serviceProxy, {
    listParser,
    initParameters: { extend: ['annotated_object'] }
  })

  const currentAttributes = computed(() =>
    annotationType.value ? ATTRIBUTES_BY_TYPE[annotationType.value] || {} : {}
  )

  function translateParameters(params) {
    const translated = { ...params }

    delete translated.annotation_type

    return translated
  }

  function setAnnotationType(typeKey) {
    annotationType.value = typeKey
    currentService.value = typeKey ? SERVICES[typeKey] : null
    filterState.resetFilter()
  }

  return {
    ...filterState,
    annotationType,
    annotationTypes,
    currentAttributes,
    setAnnotationType
  }
}
