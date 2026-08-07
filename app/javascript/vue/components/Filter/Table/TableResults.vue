<template>
  <div
    id="horizontally-scrollable"
    class="overflow-x-auto"
  >
    <table
      class="table-striped table-cell-border table-header-border full_width"
      v-resize-column
      ref="element"
    >
      <thead ref="theadRef">
        <tr v-if="headerGroups.length || layout?.properties">
          <td
            v-if="headerEmptyColspan"
            class="header-empty-td"
            :colspan="headerEmptyColspan"
          />
          <template
            v-for="header in headerGroups"
            :key="header"
          >
            <component
              v-if="!hideUnfrozen"
              :is="header.title ? 'th' : 'td'"
              :colspan="header.colspan"
              :scope="header.scope"
            >
              {{ header.title }}
            </component>
          </template>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <th
              v-if="getVisiblePropertiesCount(key, getColumns(key, properties))"
              :colspan="
                getVisiblePropertiesCount(key, getColumns(key, properties))
              "
              scope="colgroup"
              class="cell-left-border"
            >
              {{ humanize(key) }}
            </th>
          </template>

          <td
            v-if="!headerGroups.length && !isLayoutConfig"
            :colspan="Object.keys(attributes).length"
          />
        </tr>

        <tr>
          <th
            v-show="isColumnVisible(FIXED_COLUMNS.Checkbox)"
            v-bind="freezeBindings(FIXED_COLUMNS.Checkbox)"
          >
            <VLock
              :value="FIXED_COLUMNS.Checkbox"
              v-model="freezeColumn"
            />
          </th>
          <th
            v-if="radialObject || radialAnnotator || radialNavigator"
            v-show="isColumnVisible(FIXED_COLUMNS.Radial)"
            v-bind="freezeBindings(FIXED_COLUMNS.Radial)"
          >
            <VLock
              :value="FIXED_COLUMNS.Radial"
              v-model="freezeColumn"
            />
          </th>
          <th
            v-for="(_, attr) in attributes"
            :key="attr"
            v-show="isColumnVisible(attr)"
            v-bind="freezeBindings(attr)"
          >
            <ColumnHeaderActions
              :column-key="attr"
              :filtered="!!filterValues[attr]"
              v-model:freeze="freezeColumn"
              @copy="
                () =>
                  copyColumnToClipboard(
                    sanitizeHtml(
                      list
                        .filter(rowHasCurrentValues)
                        .map((item) => item[attr])
                        .join('\n')
                    )
                  )
              "
              @sort="() => sortTable(attr)"
              @clear="() => delete filterValues[attr]"
            />
          </th>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <th
              v-for="(property, pIndex) in getColumns(key, properties)"
              :key="property"
              v-show="isColumnVisible(`${key}.${property}`)"
              :class="{ 'cell-left-border': pIndex === 0 }"
              v-bind="freezeBindings(`${key}.${property}`)"
            >
              <ColumnHeaderActions
                :column-key="`${key}.${property}`"
                :filtered="!!filterValues[`${key}.${property}`]"
                v-model:freeze="freezeColumn"
                @copy="
                  () =>
                    copyColumnToClipboard(
                      props.list
                        .filter(rowHasCurrentValues)
                        .map((item) => renderItem(item, key, property))
                        .join('\n')
                    )
                "
                @sort="() => sortTable(`${key}.${property}`)"
                @clear="() => delete filterValues[`${key}.${property}`]"
              />
            </th>
          </template>
        </tr>

        <tr class="header-row-attributes">
          <th
            v-show="isColumnVisible(FIXED_COLUMNS.Checkbox)"
            class="w-2"
            :data-th-column="FIXED_COLUMNS.Checkbox"
            v-bind="freezeBindings(FIXED_COLUMNS.Checkbox)"
          >
            <input
              v-model="selectIds"
              :disabled="!list.length"
              type="checkbox"
            />
          </th>
          <th
            v-if="radialObject || radialAnnotator || radialNavigator"
            v-show="isColumnVisible(FIXED_COLUMNS.Radial)"
            class="w-2"
            :data-th-column="FIXED_COLUMNS.Radial"
            v-bind="freezeBindings(FIXED_COLUMNS.Radial)"
          />
          <th
            v-for="(title, attr) in attributes"
            :key="attr"
            v-show="isColumnVisible(attr)"
            :data-th-column="attr"
            v-bind="freezeBindings(attr)"
          >
            <div class="horizontal-left-content gap-small">
              <span>{{ title }}</span>
            </div>
          </th>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <th
              v-for="(property, pIndex) in getColumns(key, properties)"
              :key="property"
              v-show="isColumnVisible(`${key}.${property}`)"
              :class="{ 'cell-left-border': pIndex === 0 }"
              :data-th-column="`${key}.${property}`"
              v-bind="freezeBindings(`${key}.${property}`)"
            >
              <div class="horizontal-left-content gap-small">
                <span>{{ property }}</span>
              </div>
            </th>
          </template>
        </tr>
      </thead>
      <tbody @mouseout="($event) => emit('mouseout:body', $event)">
        <tr
          v-for="(item, index) in list"
          :key="item.id"
          :class="{
            'cell-selected-border': item.id === lastRadialOpenedRow
          }"
          v-bind="item._bind"
          v-show="rowHasCurrentValues(item)"
          @mouseover="() => emit('mouseover:row', { index, item })"
        >
          <td
            v-show="isColumnVisible(FIXED_COLUMNS.Checkbox)"
            v-bind="freezeBindings(FIXED_COLUMNS.Checkbox)"
          >
            <input
              v-model="ids"
              :value="item.id"
              type="checkbox"
            />
          </td>
          <td
            v-if="radialObject || radialAnnotator || radialNavigator"
            v-show="isColumnVisible(FIXED_COLUMNS.Radial)"
            v-bind="freezeBindings(FIXED_COLUMNS.Radial)"
          >
            <div class="horizontal-right-content gap-small">
              <slot
                name="buttons-left"
                :item="item"
              />
              <RadialAnnotator
                v-if="radialAnnotator"
                :global-id="item.global_id"
                reload
                teleport
                @click="() => (lastRadialOpenedRow = item.id)"
              />
              <RadialObject
                v-if="radialObject"
                :global-id="item.global_id"
                teleport
                @click="() => (lastRadialOpenedRow = item.id)"
              />
              <RadialNavigation
                v-if="radialNavigator"
                :global-id="item.global_id"
                :redirect="false"
                teleport
                @delete="emit('remove', { item, index })"
                @click="() => (lastRadialOpenedRow = item.id)"
              />
            </div>
          </td>
          <template v-if="attributes">
            <td
              v-for="(_, attr) in attributes"
              :key="attr"
              v-show="isColumnVisible(attr)"
              :name="attr"
              :value="item[attr]"
              v-bind="freezeBindings(attr)"
              @dblclick="
                () => {
                  filterValues[attr] = item[attr]
                  scrollToTop()
                  updateSelectedIdsByFilter()
                }
              "
            >
              <slot
                :name="attr"
                :value="item[attr]"
                :set-highlight="() => (lastRadialOpenedRow = item.id)"
              >
                <div v-html="item[attr]" />
              </slot>
            </td>
          </template>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <td
              v-for="(property, pIndex) in getColumns(key, properties)"
              :key="property"
              v-show="isColumnVisible(`${key}.${property}`)"
              v-html="renderItem(item, key, property)"
              :class="{ 'cell-left-border': pIndex === 0 }"
              v-bind="freezeBindings(`${key}.${property}`)"
              @dblclick="() => setColumnFilter(item, key, property)"
            />
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import {
  computed,
  nextTick,
  onBeforeUnmount,
  onMounted,
  ref,
  useTemplateRef,
  watch
} from 'vue'
import { sortArray } from '@/helpers/arrays.js'
import { vResizeColumn } from '@/directives/resizeColumn.js'
import { humanize } from '@/helpers/strings'
import { sanitizeHtml } from '@/helpers'
import { useUserPreference } from '@/composables'
import ColumnHeaderActions from './ColumnHeaderActions.vue'
import VLock from '@/components/ui/VLock/index.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import 'handy-scroll'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  modelValue: {
    type: Array,
    default: () => []
  },

  attributes: {
    type: Object,
    default: () => {}
  },

  headerGroups: {
    type: Array,
    default: () => []
  },

  layout: {
    type: Object,
    default: () => {}
  },

  radialObject: {
    type: Boolean,
    default: false
  },

  radialAnnotator: {
    type: Boolean,
    default: true
  },

  radialNavigator: {
    type: Boolean,
    default: true
  },

  preferenceKey: {
    type: String,
    default: null
  }
})

const emit = defineEmits([
  'remove',
  'onSort',
  'update:modelValue',
  'mouseover:row',
  'mouseout:body'
])

const FIXED_COLUMNS = {
  Checkbox: 'FixedCheckboxesColumn',
  Radial: 'FixedRadialColumn'
}

const hideUnfrozen = defineModel('hideUnfrozen', {
  type: Boolean,
  default: false
})

const freezeColumn = props.preferenceKey
  ? useUserPreference(`${props.preferenceKey}::freezeColumn`, [])
  : ref([])
const freezeColumnLeftPosition = ref({})

function isColumnVisible(key) {
  return !hideUnfrozen.value || freezeColumn.value.includes(key)
}

function getVisiblePropertiesCount(key, properties) {
  return properties.filter((p) => isColumnVisible(`${key}.${p}`)).length
}

function freezeBindings(key) {
  const isFrozen = freezeColumn.value.includes(key)

  return {
    class: { freeze: isFrozen },
    style: isFrozen ? { left: freezeColumnLeftPosition.value[key] } : undefined
  }
}

function generateFreezeColumnLeftPosition() {
  const obj = {}
  const sizes = {}
  const columns = [...document.querySelectorAll(`[data-th-column]`)]
    .map((el) => el.getAttribute('data-th-column'))
    .filter((attr) => freezeColumn.value.includes(attr))

  columns.forEach((attr, index) => {
    const el = document.querySelector(`[data-th-column="${attr}"]`)
    const rect = el.getBoundingClientRect()
    const sizeValues = Object.values(obj)
    const size =
      index === 0
        ? 0
        : sizeValues.slice(0, index).reduce((acc, curr) => acc + curr, 0)

    obj[attr] = rect.width
    sizes[attr] = size + 'px'
  })

  freezeColumnLeftPosition.value = sizes
}

const headerEmptyColspan = computed(() => {
  const hasRadial =
    props.radialObject || props.radialAnnotator || props.radialNavigator
  let n = 0
  if (isColumnVisible(FIXED_COLUMNS.Checkbox)) n++
  if (hasRadial && isColumnVisible(FIXED_COLUMNS.Radial)) n++
  return n
})

const ascending = ref(true)
const sortedColumn = ref(null)
const lastRadialOpenedRow = ref(null)
const handyScrollRef = useTemplateRef('handyScrollRef')
const theadRef = useTemplateRef('theadRef')
const tableRef = useTemplateRef('element')
let tableResizeObserver = null
const isLayoutConfig = computed(() => !!Object.keys(props.layout || {}).length)

const filterValues = ref({})

function getValue(item, property) {
  const properties = property.split('.')

  return properties.reduce((acc, curr) => {
    return Array.isArray(acc) ? acc.map((item) => item?.[curr]) : acc?.[curr]
  }, item)
}

function rowHasCurrentValues(item) {
  return Object.entries(filterValues.value).every(([properties, value]) => {
    const itemValue = getValue(item, properties)

    return Array.isArray(itemValue)
      ? itemValue.some((i) => value.includes(i))
      : itemValue === value
  })
}

const filteredIds = computed(() =>
  props.list.filter(rowHasCurrentValues).map((item) => item.id)
)

function clearFilterValues() {
  filterValues.value = {}
}

function resetSort() {
  sortedColumn.value = null
  ascending.value = true
}

const selectIds = computed({
  get: () =>
    filteredIds.value.length === props.modelValue.length &&
    filteredIds.value.length > 0,
  set: (value) => emit('update:modelValue', value ? [...filteredIds.value] : [])
})

const ids = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

function updateSelectedIdsByFilter() {
  ids.value = ids.value.filter((id) => filteredIds.value.includes(id))
}

function computeHeaderRowTops() {
  if (!theadRef.value) return

  let cumulative = 0
  ;[...theadRef.value.querySelectorAll('tr')].forEach((row, index) => {
    theadRef.value.style.setProperty(
      `--row-${index + 1}-top`,
      `${cumulative}px`
    )
    cumulative += row.getBoundingClientRect().height
  })
}

function copyColumnToClipboard(text) {
  navigator.clipboard
    .writeText(text)
    .then(() => {
      TW.workbench.alert.create('Copied to clipboard', 'notice')
    })
    .catch(() => {})
}

function renderItem(item, listType, property) {
  const value = item[listType]

  return Array.isArray(value)
    ? value.map((obj) => obj[property]).join('; ')
    : value && value[property]
}

function getDynamicColumns(type) {
  const [item] = props.list

  return props.layout.properties[type].show && item
    ? Object.keys(item[type])
    : []
}

function getColumns(key, properties) {
  return Array.isArray(properties) ? properties : getDynamicColumns(key)
}

function setColumnFilter(item, key, property) {
  scrollToTop()
  filterValues.value[`${key}.${property}`] = Array.isArray(item[key])
    ? item[key].map((obj) => obj[property])
    : item[key][property]
  updateSelectedIdsByFilter()
}

function sortTable(sortProperty) {
  if (sortedColumn.value === sortProperty) {
    ascending.value = !ascending.value
  } else {
    sortedColumn.value = sortProperty
    ascending.value = true
  }

  emit(
    'onSort',
    sortArray(props.list, sortProperty, ascending.value, { stripHtml: true })
  )
}

function scrollToTop() {
  document.getElementById('horizontally-scrollable')?.scrollTo(0, 0)
}

onMounted(() => {
  nextTick(computeHeaderRowTops)

  if (tableRef.value && typeof ResizeObserver !== 'undefined') {
    tableResizeObserver = new ResizeObserver(() => {
      requestAnimationFrame(generateFreezeColumnLeftPosition)
    })
    tableResizeObserver.observe(tableRef.value)
  }
})

onBeforeUnmount(() => {
  tableResizeObserver?.disconnect()
})

watch(
  () => props.list,
  (newVal, oldVal) => {
    nextTick(() => {
      handyScrollRef.value?.update()
    })

    if (oldVal && oldVal?.length === newVal?.length) {
      const ids = oldVal.map((item) => item.id)
      const hasSameIds = newVal.every((item) => ids.includes(item.id))

      if (!hasSameIds) {
        clearFilterValues()
        resetSort()
        scrollToTop()
      }
    } else {
      clearFilterValues()
      resetSort()
    }
  },
  { immediate: true }
)

watch(
  [() => props.layout, () => props.attributes, freezeColumn, hideUnfrozen],
  () =>
    nextTick(() => {
      generateFreezeColumnLeftPosition()
      computeHeaderRowTops()
    }),
  {
    deep: true
  }
)

watch(
  () => props.layout,
  () => {
    nextTick(() => {
      handyScrollRef.value?.update()
    })
  },
  { deep: true }
)

defineExpose({
  clearFilterValues
})
</script>

<style scoped>
table {
  border-collapse: separate;
}
.cell-left-border {
  border-left: 3px var(--border-color) solid;
}

.row-dwc-reindex-pending,
.cell-selected-border {
  outline-offset: -2px;

  .freeze::before {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 2px;
  }

  .freeze::after {
    content: '';
    position: absolute;
    left: 0;
    bottom: 0;
    width: 100%;
    height: 1.5px;
  }
}

.row-dwc-reindex-pending {
  outline: 2px solid var(--color-attention);

  .freeze {
    border-bottom: 1px solid var(--color-attention);
  }

  .freeze::before,
  .freeze::after {
    background-color: var(--color-attention);
  }
}

.cell-selected-border {
  outline: 2px solid var(--color-primary) !important;

  .freeze {
    border-bottom: 1px solid var(--color-primary) !important;
  }

  .freeze::before,
  .freeze::after {
    background-color: var(--color-primary);
  }
}

#horizontally-scrollable {
  height: 100%;
}

thead th,
thead td {
  position: sticky;
  background-color: var(--panel-bg-color, #fff);
  z-index: 12;
}

thead tr:nth-child(1) th,
thead tr:nth-child(1) td {
  top: var(--row-1-top, 0px);
}

thead tr:nth-child(2) th,
thead tr:nth-child(2) td {
  top: var(--row-2-top, 0px);
}

thead tr:nth-child(3) th,
thead tr:nth-child(3) td {
  top: var(--row-3-top, 0px);
}

.freeze {
  left: 0;
  position: sticky;
  z-index: 10;
}

thead .freeze {
  z-index: 15;
}

.header-empty-td {
  border-bottom: 2px solid var(--border-color);
}

.header-row-attributes {
  th {
    font-weight: 700;
  }
}

:deep(.handy-scroll) {
  z-index: 11;
}
</style>
