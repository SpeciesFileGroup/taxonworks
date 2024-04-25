<template>
  <h1>Field synchronize</h1>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
  <VSpinner
    v-if="isUpdating"
    full-screen
    legend="Saving..."
  />
  <div
    v-if="QUERY_PARAMETER[queryParam]"
    class="horizontal-left-content align-start gap-medium"
  >
    <div class="flex-col gap-medium left-column">
      <FieldForm
        :predicates="predicates"
        :attributes="[...attributes, ...noEditableAttributes].sort()"
        v-model:selected-predicates="selectedPredicates"
        v-model:selected-attributes="selectedAttributes"
      />
      <RegexForm
        :to-exclude="noEditableAttributes"
        :attributes="selectedAttributes"
        :predicates="selectedPredicates"
        v-model="regexPatterns"
        v-model:to="to"
        v-model:from="from"
      />
    </div>
    <div class="overflow-x-scroll">
      <div class="horizontal-left-content middle gap-medium">
        <VPagination
          :pagination="pagination"
          @next-page="({ page }) => loadPage(page)"
        />
        <VPaginationCount
          :pagination="pagination"
          :max-records="PER_VALUES"
          v-model="per"
        />
      </div>
      <VTable
        :attributes="selectedAttributes"
        :list="tableList"
        :no-editable="noEditableAttributes"
        :predicates="selectedPredicates"
        :preview-header="previewHeader"
        :model="currentModel"
        :is-extract="!!extractOperation"
        @remove:attribute="
          (attr) =>
            removeFromArray(selectedAttributes, attr, { primitive: true })
        "
        @remove:predicate="(item) => removeFromArray(selectedPredicates, item)"
        @update:attribute="saveFieldAttribute"
        @update:attribute-column="saveColumnAttribute"
        @update:predicate-column="saveColumnPredicate"
        @update:data-attribute="saveDataAttribute"
        @update:preview="processPreview"
        @sort="sortListByMatched"
      />
    </div>
  </div>
  <div v-else>
    <i v-if="queryParam">Query parameter is not supported</i>
    <i v-else>Query parameter is missing</i>
  </div>
</template>

<script setup>
import { onBeforeMount, ref, computed, watch } from 'vue'
import { Metadata, DataAttribute } from '@/routes/endpoints'
import { DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE } from '@/constants'
import {
  URLParamsToJSON,
  ajaxCall,
  getPagination,
  randomUUID,
  removeFromArray,
  sortArray
} from '@/helpers'
import { QUERY_PARAMETER, PATTERN_TYPES } from './constants'
import VTable from './components/Table/VTable.vue'
import RegexForm from './components/Regex/RegexForm.vue'
import FieldForm from './components/Field/FieldForm.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VPaginationCount from '@/components/pagination/PaginationCount.vue'
import VPagination from '@/components/pagination.vue'
import Qs from 'qs'
import { applyRegex, applyExtract } from './utils'
import { useQueryParam } from './composables'

defineOptions({
  name: 'FieldSynchronize'
})

const PER_VALUES = [50, 100, 200, 250]

const { queryParam, queryValue } = useQueryParam()
const attributes = ref([])
const noEditableAttributes = ref([])
const list = ref([])
const selectedAttributes = ref([])
const selectedPredicates = ref([])
const predicates = ref([])
const dataAttributes = ref([])
const from = ref()
const to = ref()
const regexPatterns = ref([])
const isLoading = ref(false)
const isUpdating = ref(false)

const pagination = ref({})
const per = ref(250)
const currentPage = ref(1)

const currentModel = computed(() => QUERY_PARAMETER[queryParam.value]?.model)

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

function makePreviewObject(newVal, oldVal) {
  return {
    value: newVal,
    hasChanged: newVal !== oldVal
  }
}

function makeDataAttribute({ predicateId, value = '', id = null }) {
  return {
    id,
    uuid: randomUUID(),
    predicateId,
    value
  }
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

  makeNotificationWhenPromisesEnd(promises).then((_) => {
    isUpdating.value = false
  })
}

function makeNotificationWhenPromisesEnd(promises) {
  const handlePromises = Promise.allSettled(promises)

  handlePromises.then((res) => {
    const resolvedCount = res.filter((r) => r.status === 'fulfilled').length
    const rejectedCount = (promises.length = resolvedCount)

    const message = rejectedCount.length
      ? `${resolvedCount} record(s) were successfully saved. ${rejectedCount} were not saved`
      : `${resolvedCount} record(s) were successfully saved`

    TW.workbench.alert.create(message)
  })

  return handlePromises
}

function saveColumnAttribute(items) {
  const requests = items.map((item) => saveFieldAttribute(item))

  isUpdating.value = true
  makeNotificationWhenPromisesEnd(requests).then((res) => {
    isUpdating.value = false
  })
}

function saveColumnPredicate(items) {
  const requests = items.map((item) => saveDataAttribute(item))

  isUpdating.value = true
  makeNotificationWhenPromisesEnd(requests).then((res) => {
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
    .then((_) => {
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

    dataAttributes.value = makeDataAttributeList(body)
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
        serialize: (params) => Qs.stringify(params, { arrayFormat: 'brackets' })
      }
    }
  )

  request
    .then((response) => {
      pagination.value = getPagination(response)
      list.value = response.body.map((item) => {
        const { id, ...attributes } = item

        if (!dataAttributes.value[id]) {
          dataAttributes.value[id] = fillDataAttributes({})
        }

        return {
          id,
          uuid: randomUUID(),
          attributes,
          dataAttributes: dataAttributes.value[id]
        }
      })
    })
    .finally(() => {
      isLoading.value = false
    })

  return request
}

function fillDataAttributes(obj) {
  predicates.value.forEach(({ id }) => {
    if (!obj[id]) {
      obj[id] = [makeDataAttribute({ predicateId: id })]
    }
  })

  return obj
}

function makeDataAttributeList({ data }) {
  const obj = {}

  data.forEach(([id, objectId, predicateId, value]) => {
    const dataAttribute = makeDataAttribute({
      id,
      predicateId,
      value,
      objectId
    })
    const dataAttributes = obj[objectId]

    if (dataAttributes) {
      const arr = dataAttributes[predicateId]

      if (arr) {
        arr.push(dataAttribute)
      } else {
        dataAttributes[predicateId] = [dataAttribute]
      }
    } else {
      obj[objectId] = {
        [predicateId]: [dataAttribute]
      }
    }
  })

  for (const key in obj) {
    fillDataAttributes(obj[key])
  }

  return obj
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
</script>

<style scoped>
.left-column {
  width: 440px;
}
</style>
