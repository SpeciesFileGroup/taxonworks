import { onBeforeMount, ref, computed, watch } from 'vue'
import { Metadata, DataAttribute } from '@/routes/endpoints'
import { DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE } from '@/constants'
import { QUERY_PARAMETER, PATTERN_TYPES } from '../constants'
import {
  applyRegex,
  applyExtract,
  fillDataAttributes,
  makeNotificationWhenPromisesEnd
} from '../utils'
import { useQueryParam } from './index'
import {
  URLParamsToJSON,
  ajaxCall,
  getPagination,
  randomUUID,
  removeFromArray
} from '@/helpers'
import {
  makeDataAttribute,
  makeDataAttributeList,
  makePreviewObject
} from '../factory'
import Qs from 'qs'

export function useFieldSync() {
  const attributes = ref([])
  const dataAttributes = ref([])
  const from = ref()
  const isLoading = ref(false)
  const isUpdating = ref(false)
  const list = ref([])
  const noEditableAttributes = ref([])
  const predicates = ref([])
  const regexPatterns = ref([])
  const selectedAttributes = ref([])
  const selectedPredicates = ref([])
  const updatedCount = ref(0)
  const totalUpdate = ref(0)
  const to = ref()
  const { queryParam, queryValue } = useQueryParam()

  const pagination = ref({})
  const per = ref(250)
  const currentPage = ref(1)

  const currentModel = computed(() => QUERY_PARAMETER[queryParam.value]?.model)

  const filterUrl = computed(() => {
    const url = QUERY_PARAMETER[queryParam.value]?.filterUrl

    return url
      ? url + '?' + Qs.stringify(queryValue.value, { arrayFormat: 'brackets' })
      : ''
  })

  const previewHeader = computed(() => {
    const _from = from.value?.name || from.value
    const _to = to.value?.name || to.value

    if (!_from || !_to) {
      return []
    }

    return extractOperation.value ? [_from, _to] : [`${_from}→${_to}`]
  })

  const extractOperation = computed(() =>
    regexPatterns.value.find((item) => item.mode === PATTERN_TYPES.Extract)
  )

  const tableList = computed(() => {
    function getItemsFromObj(obj, property) {
      return property?.id
        ? obj.dataAttributes[property.id].map((item) => item.value)
        : [obj.attributes[property]]
    }

    return list.value.map((item) => {
      const data = {
        ...item
      }

      if (from.value && to.value) {
        const fromItems = getItemsFromObj(item, from.value)

        if (extractOperation.value) {
          const toItems = getItemsFromObj(item, to.value)

          data.preview = fromItems.map((fromValue, index) => {
            const toValue = toItems[index]
            const newValue = applyExtract(
              extractOperation.value,
              fromValue,
              toValue
            )

            const payload = {
              to: makePreviewObject(newValue.to, toValue),
              from: makePreviewObject(newValue.from, fromValue)
            }

            if (extractOperation.value.emptyOnly && toValue) {
              payload.to.hasChanged = false
            }

            return payload
          })
        } else {
          data.preview = fromItems.map((value) => {
            const newValue =
              value && regexPatterns.value.length
                ? applyRegex(value, regexPatterns.value)
                : value

            return {
              to: makePreviewObject(newValue, value)
            }
          })
        }
      }

      return data
    })
  })

  function sortListByMatched() {
    const itemsChangedId = tableList.value
      .filter((item) => item.preview.some((p) => p.to.hasChanged))
      .map((item) => item.id)

    list.value = [
      ...list.value.filter((item) => itemsChangedId.includes(item.id)),
      ...list.value.filter((item) => !itemsChangedId.includes(item.id))
    ]
  }

  function sortListByEmpty(property) {
    const predicateId = property?.id
    const itemsWithValue = list.value
      .filter((item) =>
        predicateId
          ? item.dataAttributes[predicateId].some((d) => d.value)
          : item.attributes[property]
      )
      .map((item) => item.id)

    list.value = [
      ...list.value.filter((item) => !itemsWithValue.includes(item.id)),
      ...list.value.filter((item) => itemsWithValue.includes(item.id))
    ]
  }

  function processPreview({ fromItems = [], toItems = [] }) {
    const fromPredicateId = from.value?.id
    const toPredicateId = to.value?.id

    updatedCount.value = 0
    totalUpdate.value = fromItems.length + toItems.length

    function requestItems(items, predicateId, attribute) {
      return items.map(({ item, index, value }) => {
        let request

        if (predicateId) {
          const dataAttribute = item.dataAttributes[predicateId][index]

          request = saveDataAttribute({
            ...dataAttribute,
            objectId: item.id,
            value
          })
        } else {
          request = saveFieldAttribute({ item, attribute, value })
        }

        request
          .finally(() => {
            updatedCount.value++
          })
          .catch(() => {})

        return request
      })
    }

    const promises = [
      ...requestItems(fromItems, fromPredicateId, from.value),
      ...requestItems(toItems, toPredicateId, to.value)
    ]

    isUpdating.value = true

    makeNotificationWhenPromisesEnd(promises).then(() => {
      isUpdating.value = false
    })
  }

  function saveColumnAttribute(items) {
    const requests = items.map((item) => saveFieldAttribute(item))

    handleRequestsFromColumnUpdate(requests)
  }

  function saveColumnPredicate(items) {
    const requests = items.map((item) => saveDataAttribute(item))

    handleRequestsFromColumnUpdate(requests)
  }

  function handleRequestsFromColumnUpdate(requests) {
    totalUpdate.value = requests.length
    updatedCount.value = 0

    requests.forEach((item) => {
      item
        .finally(() => {
          updatedCount.value++
        })
        .catch(() => {})
    })

    isUpdating.value = true
    makeNotificationWhenPromisesEnd(requests).then(() => {
      isUpdating.value = false
    })
  }

  function saveFieldAttribute({ item, attribute, value }) {
    const { service } = QUERY_PARAMETER[queryParam.value]
    const objectParam = queryParam.value.slice(0, -6)

    const request = service.update(item.id, {
      [objectParam]: {
        [attribute]: value
      }
    })

    request
      .then(({ body }) => {
        const currentItem = list.value.find((obj) => obj.id === item.id)

        currentItem.attributes[attribute] = body[attribute]
      })
      .catch(() => {})

    return request
  }

  watch(selectedAttributes, (newVal) => {
    if (newVal.length) {
      loadPage(currentPage.value)
    }
  })

  watch(per, () => {
    loadPage(1)
  })

  function saveDataAttribute({ id, value, objectId, predicateId, uuid }) {
    const objectItem = list.value.find((item) => item.id === objectId)
    const predicates = objectItem.dataAttributes[predicateId]
    const payload = {
      data_attribute: {
        controlled_vocabulary_term_id: predicateId,
        attribute_subject_id: objectId,
        attribute_subject_type: currentModel.value,
        type: DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE,
        value
      }
    }

    if (!value) {
      const request = DataAttribute.destroy(id)

      request
        .then(() => {
          removeFromArray(predicates, { uuid }, { property: 'uuid' })

          if (!predicates.length) {
            predicates.push(makeDataAttribute({ predicateId }))
          }
        })
        .catch(() => {})

      return request
    }

    const request = id
      ? DataAttribute.update(id, payload)
      : DataAttribute.create(payload)

    request
      .then(({ body }) => {
        const _dataAttributes = dataAttributes.value[objectId][predicateId]
        const da = _dataAttributes.find((item) => item.uuid === uuid)
        const currentDa = predicates.find((item) => item.uuid === uuid)

        da.id = body.id
        da.value = body.value
        currentDa.value = body.id
        currentDa.value = body.value

        TW.workbench.alert.create('Data attribute was successfully saved')
      })
      .catch(() => {})

    return request
  }

  function loadPredicates(params) {
    const request = DataAttribute.brief({
      ...params,
      type: DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE
    })

    request.then(({ body }) => {
      predicates.value = body.index.map((item) => {
        const [id] = Object.keys(item)
        const [name] = Object.values(item)

        return {
          id: Number(id),
          name
        }
      })

      dataAttributes.value = makeDataAttributeList({
        data: body.data,
        predicates: predicates.value
      })
    })

    return request
  }

  function loadAttributes(params) {
    const request = ajaxCall(
      'get',
      '/tasks/data_attributes/field_synchronize/values',
      {
        params,
        paramsSerializer: {
          serialize: (params) =>
            Qs.stringify(params, { arrayFormat: 'brackets' })
        }
      }
    )

    request.then((response) => {
      pagination.value = getPagination(response)
      list.value = response.body.map((item) => {
        const { id, ...attributes } = item

        if (!dataAttributes.value[id]) {
          dataAttributes.value[id] = fillDataAttributes({}, predicates.value)
        }

        return {
          id,
          uuid: randomUUID(),
          attributes,
          dataAttributes: dataAttributes.value[id]
        }
      })
    })

    return request
  }

  function removeSelectedAttribute(attr) {
    removeFromArray(selectedAttributes.value, attr, { primitive: true })

    if (from.value === attr) {
      from.value = null
    }

    if (to.value === attr) {
      to.value = null
    }
  }

  function removeSelectedPredicate(predicate) {
    removeFromArray(selectedPredicates.value, predicate)

    if (from.value?.id === predicate.id) {
      from.value = null
    }

    if (to.value?.id === predicate.id) {
      to.value = null
    }
  }

  onBeforeMount(async () => {
    const { attribute } = URLParamsToJSON(window.location.href)

    if (currentModel.value) {
      attributes.value = (
        await Metadata.attributes({
          model: currentModel.value,
          mode: 'editable'
        })
      ).body

      noEditableAttributes.value = (
        await Metadata.attributes({ model: currentModel.value })
      ).body.filter((item) => !attributes.value.includes(item))

      if (Array.isArray(attribute)) {
        selectedAttributes.value.push(...attribute)
      }

      loadPage(currentPage.value)
    }
  })

  async function loadPage(page) {
    isLoading.value = true
    currentPage.value = page

    await loadPredicates({
      [queryParam.value]: {
        ...queryValue.value,
        paginate: true,
        page,
        per: per.value
      }
    })

    await loadAttributes({
      [queryParam.value]: queryValue.value,
      attribute: selectedAttributes.value,
      page,
      per: per.value
    })

    selectedPredicates.value = selectedPredicates.value.filter((item) =>
      predicates.value.some((p) => p.id === item.id)
    )

    isLoading.value = false
  }

  return {
    attributes,
    currentModel,
    extractOperation,
    filterUrl,
    from,
    isLoading,
    isUpdating,
    loadPage,
    noEditableAttributes,
    pagination,
    per,
    predicates,
    previewHeader,
    processPreview,
    queryParam,
    queryValue,
    regexPatterns,
    removeSelectedAttribute,
    removeSelectedPredicate,
    saveColumnAttribute,
    saveColumnPredicate,
    saveDataAttribute,
    saveFieldAttribute,
    selectedAttributes,
    selectedPredicates,
    sortListByEmpty,
    sortListByMatched,
    tableList,
    updatedCount,
    totalUpdate,
    to
  }
}
