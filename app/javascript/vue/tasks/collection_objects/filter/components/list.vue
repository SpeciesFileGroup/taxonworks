<template>
  <HandyScroll>
    <table
      class="full_width"
      ref="tableElement"
      v-resize-column
    >
      <thead>
        <tr>
          <td colspan="2" />
          <template
            v-for="(properties, key) in layout.properties"
            :key="key"
          >
            <th
              v-if="properties.length"
              :colspan="properties.length"
              scope="colgroup"
              class="cell-left-border"
            >
              {{ humanize(key) }}
            </th>
          </template>
          <th
            v-if="layout.includes.data_attributes"
            :colspan="dataAttributeHeaders.length"
            scope="colgroup"
            class="cell-left-border"
          >
            Data attributes
          </th>
        </tr>
        <tr>
          <th class="w-2">
            <input
              type="checkbox"
              v-model="selectIds"
            />
          </th>
          <th class="w-2" />
          <template
            v-for="(propertiesList, key) in layout.properties"
            :key="key"
          >
            <th
              v-for="(property, pIndex) in propertiesList"
              :key="property"
              :class="{ 'cell-left-border': pIndex === 0 }"
              @click="
                sortTable(key === props.base ? property : `${key}.${property}`)
              "
            >
              {{ property }}
            </th>
          </template>
          <th
            v-for="(header, index) in dataAttributeHeaders"
            :class="{ 'cell-left-border': index === 0 }"
            :key="header"
          >
            {{ header }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in list"
          :key="item.id"
          class="contextMenuCells"
          :class="{ even: index % 2 }"
        >
          <td>
            <input
              v-model="ids"
              :value="item.id"
              type="checkbox"
            />
          </td>
          <td>
            <div class="horizontal-left-content">
              <RadialAnnotator :global-id="item.global_id" />
              <RadialObject :global-id="item.global_id" />
              <RadialNavigation :global-id="item.global_id" />
            </div>
          </td>
          <template
            v-for="(properties, key) in props.layout.properties"
            :key="key"
          >
            <td
              v-for="(property, pIndex) in properties"
              :key="property"
              v-html="renderItem(item, key, property)"
              :class="{ 'cell-left-border': pIndex === 0 }"
            />
          </template>
          <td
            v-for="(predicateName, dIndex) in dataAttributeHeaders"
            :key="predicateName"
            :class="{ 'cell-left-border': dIndex === 0 }"
            v-text="renderDataAttribute(item.data_attributes, predicateName)"
          />
        </tr>
      </tbody>
    </table>
  </HandyScroll>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn.js'
import { humanize } from 'helpers/strings'
import HandyScroll from 'vue-handy-scroll'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/object/radial.vue'
import RadialNavigation from 'components/radials/navigation/radial.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  modelValue: {
    type: Array,
    default: () => []
  },

  base: {
    type: String,
    default: 'base'
  },

  layout: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['onSort', 'update:modelValue'])
const tableElement = ref(null)
const ascending = ref(false)

const ids = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

const selectIds = computed({
  get: () => props.list.length === ids.value.length,
  set: (value) => {
    ids.value = value ? props.list.map((r) => r.id) : []
  }
})

const dataAttributeHeaders = computed(() => {
  if (!props.layout.includes.data_attributes) return

  const predicateNames = []

  props.list.forEach((item) => {
    item?.data_attributes?.forEach((da) => {
      if (!predicateNames.includes(da.predicate_name)) {
        predicateNames.push(da.predicate_name)
      }
    })
  })

  return predicateNames
})

function renderItem(item, listType, property) {
  if (listType === props.base) {
    return item[property]
  } else {
    const value = item[listType]

    return Array.isArray(value)
      ? value.map((obj) => obj[property]).join('; ')
      : value && value[property]
  }
}

function renderDataAttribute(dataAttributes, predicateName) {
  const da = dataAttributes.find((d) => d.predicate_name === predicateName)

  return da && da.value
}

function sortTable(sortProperty) {
  emit('onSort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}

watch(
  () => props.layout,
  () =>
    HandyScroll.EventBus.emit('update', { sourceElement: tableElement.value }),
  { deep: true }
)
</script>

<style lang="scss" scoped>
tr {
  height: 44px;
}
.options-column {
  width: 130px;
}

td {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

td:hover {
  max-width: 200px;
  text-overflow: ellipsis;
  white-space: normal;
}

.cell-left-border {
  border-left: 3px #eaeaea solid;
}
</style>
