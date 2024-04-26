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

            return {
              to: makePreviewObject(newValue.to, toValue),
              from: makePreviewObject(newValue.from, fromValue)
            }
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

  function processPreview({ fromItems = [], toItems = [] }) {
    const fromPredicateId = from.value?.id
    const toPredicateId = to.value?.id

    function requestItems(items, predicateId, attribute) {
      return items.map(({ item, index, value }) => {
        if (predicateId) {
          const dataAttribute = item.dataAttributes[predicateId][index]

          return saveDataAttribute({
            ...dataAttribute,
            objectId: item.id,
            value
          })
        }

        return saveFieldAttribute({ item, attribute, value })
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

    isUpdating.value = true
    makeNotificationWhenPromisesEnd(requests).then(() => {
      isUpdating.value = false
    })
  }

  function saveColumnPredicate(items) {
    const requests = items.map((item) => saveDataAttribute(item))

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
      .then(() => {
        const currentItem = list.value.find((obj) => obj.id === item.id)

        currentItem.attributes[attribute] = value
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

      request.then(() => {
        removeFromArray(predicates, { uuid }, { property: 'uuid' })

        if (!predicates.length) {
          predicates.push(makeDataAttribute({ predicateId }))
        }
      })

      return request
    }

    const request = id
      ? DataAttribute.update(id, payload)
      : DataAttribute.create(payload)

    request.then(({ body }) => {
      const _dataAttributes = dataAttributes.value[objectId][predicateId]
      const da = _dataAttributes.find((item) => item.uuid === uuid)
      const currentDa = predicates.find((item) => item.uuid === uuid)

      da.id = body.id
      da.value = body.value
      currentDa.value = body.id
      currentDa.value = body.value

      TW.workbench.alert.create('Data attribute was successfully saved')
    })

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
    saveColumnAttribute,
    saveColumnPredicate,
    saveDataAttribute,
    saveFieldAttribute,
    selectedAttributes,
    selectedPredicates,
    sortListByMatched,
    tableList,
    to
  }
}
