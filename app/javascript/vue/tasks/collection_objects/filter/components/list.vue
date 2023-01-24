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
              @click="sortTable(`${key}.${property}`)"
            >
              {{ property }}
              <button
                type="button"
                v-if="filterValues[`${key}.${property}`]"
                @click.stop="
                  () => {
                    delete filterValues[`${key}.${property}`]
                  }
                "
              >
                X
              </button>
            </th>
          </template>
          <th
            v-for="(header, index) in dataAttributeHeaders"
            :class="{ 'cell-left-border': index === 0 }"
            :key="header"
            @click="sortTable(`data_attributes.${header}`)"
          >
            {{ header }}
          </th>
        </tr>
      </thead>
      <tbody>
        <template
          v-for="(item, index) in list"
          :key="item.id"
        >
          <tr
            v-show="rowHasCurrentValues(item)"
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
                @dblclick="
                  () => {
                    filterValues[
                      Array.isArray(item[key]) ? `${key}` : `${key}.${property}`
                    ] = Array.isArray(item[key])
                      ? item[key]
                      : item[key][property]
                  }
                "
              />
            </template>
            <td
              v-for="(predicateName, dIndex) in dataAttributeHeaders"
              :key="predicateName"
              :class="{ 'cell-left-border': dIndex === 0 }"
              v-text="renderDataAttribute(item.data_attributes, predicateName)"
            />
          </tr>
        </template>
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
    default: 'collection_object'
  },

  layout: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['onSort', 'update:modelValue'])
const tableElement = ref(null)
const ascending = ref(false)

const filterValues = ref({})

function rowHasCurrentValues(item) {
  return Object.entries(filterValues.value).every(
    ([properties, value]) => getValue(item, properties) === value
  )
}

function getValue(item, property) {
  const properties = property.split('.')

  return properties.reduce((acc, curr) => acc[curr], item)
}

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
    Object.keys(item.data_attributes || {}).forEach((name) => {
      if (!predicateNames.includes(name)) {
        predicateNames.push(name)
      }
    })
  })

  return predicateNames.sort()
})

function renderItem(item, listType, property) {
  const value = item[listType]

  return Array.isArray(value)
    ? value.map((obj) => obj[property]).join('; ')
    : value && value[property]
}

function renderDataAttribute(dataAttributes, predicateName) {
  const key = Object.keys(dataAttributes).find((key) => key === predicateName)

  return dataAttributes[key]
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
