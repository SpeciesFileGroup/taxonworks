<template>
  <HandyScroll>
    <table
      class="table-striped table-cell-border table-header-border full_width"
      v-resize-column
      ref="element"
    >
      <thead>
        <tr v-if="headerGroups.length || layout?.properties">
          <td
            class="header-empty-td"
            :colspan="
              radialObject || radialAnnotator || radialNavigator ? 2 : 1
            "
          />
          <template
            v-for="header in headerGroups"
            :key="header"
          >
            <component
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
            <template v-if="Array.isArray(properties)">
              <th
                v-if="properties.length"
                :colspan="properties.length"
                scope="colgroup"
                class="cell-left-border"
              >
                {{ humanize(key) }}
              </th>
            </template>
            <template v-else>
              <th
                v-if="getDynamicColumns(key).length"
                scope="colgroup"
                class="cell-left-border"
                :colspan="getDynamicColumns(key).length"
              >
                {{ humanize(key) }}
              </th>
            </template>
          </template>

          <td
            v-if="!headerGroups.length && !isLayoutConfig"
            :colspan="Object.keys(attributes).length"
          />
        </tr>

        <tr>
          <th
            :class="[{ freeze: freezeColumn.includes(FIXED_COLUMNS.Checkbox) }]"
            :style="
              freezeColumn.includes(FIXED_COLUMNS.Checkbox) && {
                left: freezeColumnLeftPosition[FIXED_COLUMNS.Checkbox]
              }
            "
          >
            <VLock
              :value="FIXED_COLUMNS.Checkbox"
              v-model="freezeColumn"
            />
          </th>
          <th
            v-if="radialObject || radialAnnotator || radialNavigator"
            :class="[{ freeze: freezeColumn.includes(FIXED_COLUMNS.Radial) }]"
            :style="
              freezeColumn.includes(FIXED_COLUMNS.Radial) && {
                left: freezeColumnLeftPosition[FIXED_COLUMNS.Radial]
              }
            "
          >
            <VLock
              :value="FIXED_COLUMNS.Radial"
              v-model="freezeColumn"
            />
          </th>
          <th
            v-for="(title, attr) in attributes"
            :key="attr"
            :class="[{ freeze: freezeColumn.includes(attr) }]"
            :style="
              freezeColumn.includes(attr) && {
                left: freezeColumnLeftPosition[attr]
              }
            "
          >
            <div class="horizontal-left-content gap-small">
              <VLock
                :value="attr"
                v-model="freezeColumn"
              />

              <VBtn
                color="primary"
                circle
                title="Copy column to clipboard"
                @click.stop="
                  () =>
                    copyColumnToClipboard(
                      list
                        .filter(rowHasCurrentValues)
                        .map((item) => item[attr])
                        .join('\n')
                    )
                "
              >
                <VIcon
                  name="clip"
                  title="Copy column to clipboard"
                  x-small
                />
              </VBtn>
              <VBtn
                title="Sort alphabetically"
                color="primary"
                circle
                @click.stop="() => sortTable(attr)"
              >
                <VIcon
                  name="alphabeticalSort"
                  title="Sort alphabetically"
                  x-small
                />
              </VBtn>
              <VBtn
                v-if="filterValues[attr]"
                color="primary"
                circle
                @click.stop="
                  () => {
                    delete filterValues[attr]
                  }
                "
              >
                X
              </VBtn>
            </div>
          </th>

          <template
            v-for="(propertiesList, key) in layout?.properties"
            :key="key"
          >
            <template v-if="Array.isArray(propertiesList)">
              <th
                v-for="(property, pIndex) in propertiesList"
                :key="property"
                :class="{
                  'cell-left-border': pIndex === 0,
                  freeze: freezeColumn.includes(`${key}.${property}`)
                }"
                :style="
                  freezeColumn.includes(`${key}.${property}`) && {
                    left: freezeColumnLeftPosition[`${key}.${property}`]
                  }
                "
              >
                <div class="horizontal-left-content gap-small">
                  <VLock
                    :value="`${key}.${property}`"
                    v-model="freezeColumn"
                  />
                  <VBtn
                    color="primary"
                    circle
                    title="Copy column to clipboard"
                    @click.stop="
                      () =>
                        copyColumnToClipboard(
                          props.list
                            .filter(rowHasCurrentValues)
                            .map((item) => renderItem(item, key, property))
                            .join('\n')
                        )
                    "
                  >
                    <VIcon
                      name="clip"
                      title="Copy column to clipboard"
                      x-small
                    />
                  </VBtn>
                  <VBtn
                    title="Sort alphabetically"
                    color="primary"
                    circle
                    @click.stop="() => sortTable(`${key}.${property}`)"
                  >
                    <VIcon
                      name="alphabeticalSort"
                      title="Sort alphabetically"
                      x-small
                    />
                  </VBtn>
                  <VBtn
                    v-if="filterValues[`${key}.${property}`]"
                    color="primary"
                    circle
                    @click.stop="
                      () => {
                        delete filterValues[`${key}.${property}`]
                      }
                    "
                  >
                    X
                  </VBtn>
                </div>
              </th>
            </template>
            <template v-else>
              <th
                v-for="(property, pIndex) in getDynamicColumns(key)"
                :key="property"
                :class="{
                  'cell-left-border': pIndex === 0,
                  freeze: freezeColumn.includes(`${key}.${property}`)
                }"
                :style="
                  freezeColumn.includes(`${key}.${property}`) && {
                    left: freezeColumnLeftPosition[`${key}.${property}`]
                  }
                "
              >
                <div class="horizontal-left-content gap-small">
                  <VLock
                    :value="`${key}.${property}`"
                    v-model="freezeColumn"
                  />
                  <VBtn
                    color="primary"
                    circle
                    title="Copy column to clipboard"
                    @click.stop="
                      () =>
                        copyColumnToClipboard(
                          props.list
                            .filter(rowHasCurrentValues)
                            .map((item) => renderItem(item, key, property))
                            .join('\n')
                        )
                    "
                  >
                    <VIcon
                      name="clip"
                      title="Copy column to clipboard"
                      x-small
                    />
                  </VBtn>
                  <VBtn
                    title="Sort alphabetically"
                    color="primary"
                    circle
                    @click.stop="() => sortTable(`${key}.${property}`)"
                  >
                    <VIcon
                      name="alphabeticalSort"
                      title="Sort alphabetically"
                      x-small
                    />
                  </VBtn>
                  <VBtn
                    v-if="filterValues[`${key}.${property}`]"
                    color="primary"
                    circle
                    @click.stop="
                      () => {
                        delete filterValues[`${key}.${property}`]
                      }
                    "
                  >
                    X
                  </VBtn>
                </div>
              </th>
            </template>
          </template>
        </tr>

        <tr class="header-row-attributes">
          <th
            :class="[
              'w-2',
              { freeze: freezeColumn.includes(FIXED_COLUMNS.Checkbox) }
            ]"
            :data-th-column="FIXED_COLUMNS.Checkbox"
            :style="
              freezeColumn.includes(FIXED_COLUMNS.Checkbox) && {
                left: freezeColumnLeftPosition[FIXED_COLUMNS.Checkbox]
              }
            "
          >
            <input
              v-model="selectIds"
              :disabled="!list.length"
              type="checkbox"
            />
          </th>
          <th
            v-if="radialObject || radialAnnotator || radialNavigator"
            :class="[
              'w-2',
              { freeze: freezeColumn.includes(FIXED_COLUMNS.Radial) }
            ]"
            :data-th-column="FIXED_COLUMNS.Radial"
            :style="
              freezeColumn.includes(FIXED_COLUMNS.Radial) && {
                left: freezeColumnLeftPosition[FIXED_COLUMNS.Radial]
              }
            "
          />
          <th
            v-for="(title, attr) in attributes"
            :key="attr"
            :class="{ freeze: freezeColumn.includes(attr) }"
            :style="
              freezeColumn.includes(attr) && {
                left: freezeColumnLeftPosition[attr]
              }
            "
            :data-th-column="attr"
          >
            <div class="horizontal-left-content gap-small">
              <span>{{ title }}</span>
            </div>
          </th>

          <template
            v-for="(propertiesList, key) in layout?.properties"
            :key="key"
          >
            <template v-if="Array.isArray(propertiesList)">
              <th
                v-for="(property, pIndex) in propertiesList"
                :key="property"
                :class="{
                  'cell-left-border': pIndex === 0,
                  freeze: freezeColumn.includes(`${key}.${property}`)
                }"
                :data-th-column="`${key}.${property}`"
                :style="
                  freezeColumn.includes(`${key}.${property}`) && {
                    left: freezeColumnLeftPosition[`${key}.${property}`]
                  }
                "
              >
                <div class="horizontal-left-content gap-small">
                  <span>{{ property }}</span>
                </div>
              </th>
            </template>
            <template v-else>
              <th
                v-for="(property, pIndex) in getDynamicColumns(key)"
                :key="property"
                :class="{
                  'cell-left-border': pIndex === 0,
                  freeze: freezeColumn.includes(`${key}.${property}`)
                }"
                :data-th-column="`${key}.${property}`"
                :style="
                  freezeColumn.includes(`${key}.${property}`) && {
                    left: freezeColumnLeftPosition[`${key}.${property}`]
                  }
                "
              >
                <div class="horizontal-left-content gap-small">
                  <span>{{ property }}</span>
                </div>
              </th>
            </template>
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
            :class="{ freeze: freezeColumn.includes(FIXED_COLUMNS.Checkbox) }"
            :style="
              freezeColumn.includes(FIXED_COLUMNS.Checkbox) && {
                left: freezeColumnLeftPosition[FIXED_COLUMNS.Checkbox]
              }
            "
          >
            <input
              v-model="ids"
              :value="item.id"
              type="checkbox"
            />
          </td>
          <td
            v-if="radialObject || radialAnnotator || radialNavigator"
            :class="{ freeze: freezeColumn.includes(FIXED_COLUMNS.Radial) }"
            :style="
              freezeColumn.includes(FIXED_COLUMNS.Radial) && {
                left: freezeColumnLeftPosition[FIXED_COLUMNS.Radial]
              }
            "
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
              :name="attr"
              :value="item[attr]"
              :class="{ freeze: freezeColumn.includes(attr) }"
              :style="
                freezeColumn.includes(attr) && {
                  left: freezeColumnLeftPosition[attr]
                }
              "
              @dblclick="
                () => {
                  scrollToTop()
                  filterValues[attr] = item[attr]
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
            <template v-if="!Array.isArray(properties)">
              <template v-if="properties?.show">
                <td
                  v-for="(value, property, dIndex) in item[key]"
                  :key="property"
                  :class="{
                    'cell-left-border': dIndex === 0,
                    freeze: freezeColumn.includes(`${key}.${property}`)
                  }"
                  :style="
                    freezeColumn.includes(`${key}.${property}`) && {
                      left: freezeColumnLeftPosition[`${key}.${property}`]
                    }
                  "
                  @dblclick="
                    () => {
                      scrollToTop()
                      filterValues[`${key}.${property}`] = Array.isArray(
                        item[key]
                      )
                        ? item[key].map((obj) => obj[property])
                        : item[key][property]
                    }
                  "
                  v-text="value"
                />
              </template>
            </template>
            <template v-else>
              <td
                v-for="(property, pIndex) in properties"
                :key="property"
                v-html="renderItem(item, key, property)"
                :class="{
                  'cell-left-border': pIndex === 0,
                  freeze: freezeColumn.includes(`${key}.${property}`)
                }"
                :style="
                  freezeColumn.includes(`${key}.${property}`) && {
                    left: freezeColumnLeftPosition[`${key}.${property}`]
                  }
                "
                @dblclick="
                  () => {
                    scrollToTop()
                    filterValues[`${key}.${property}`] = Array.isArray(
                      item[key]
                    )
                      ? item[key].map((obj) => obj[property])
                      : item[key][property]
                  }
                "
              />
            </template>
          </template>
        </tr>
      </tbody>
    </table>
  </HandyScroll>
</template>

<script setup>
import { computed, nextTick, ref, watch } from 'vue'
import { sortArray } from '@/helpers/arrays.js'
import { vResizeColumn } from '@/directives/resizeColumn.js'
import { humanize } from '@/helpers/strings'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VLock from '@/components/ui/VLock/index.vue'
import HandyScroll from 'vue-handy-scroll'
import RadialNavigation from '@/components/radials/navigation/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'

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

const freezeColumn = ref([])
const freezeColumnLeftPosition = ref({})
const element = ref(null)
const ascending = ref(false)
const lastRadialOpenedRow = ref(null)
const isLayoutConfig = computed(() => !!Object.keys(props.layout || {}).length)

const selectIds = computed({
  get: () =>
    props.list.length === props.modelValue.length && props.list.length > 0,
  set: (value) =>
    emit('update:modelValue', value ? props.list.map((item) => item.id) : [])
})

const ids = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const filterValues = ref({})

function copyColumnToClipboard(text) {
  navigator.clipboard
    .writeText(text)
    .then(() => {
      TW.workbench.alert.create('Copied to clipboard', 'notice')
    })
    .catch(() => {})
}

function rowHasCurrentValues(item) {
  return Object.entries(filterValues.value).every(([properties, value]) => {
    const itemValue = getValue(item, properties)

    return Array.isArray(itemValue)
      ? itemValue.some((i) => value.includes(i))
      : itemValue === value
  })
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

function getValue(item, property) {
  const properties = property.split('.')

  return properties.reduce((acc, curr) => {
    return Array.isArray(acc) ? acc.map((item) => item?.[curr]) : acc?.[curr]
  }, item)
}

function sortTable(sortProperty) {
  emit(
    'onSort',
    sortArray(props.list, sortProperty, ascending.value, { stripHtml: true })
  )
  ascending.value = !ascending.value
}

function scrollToTop() {
  window.scrollTo(0, 0)
}

function clearFilterValues() {
  filterValues.value = {}
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

watch(
  () => props.list,
  (newVal, oldVal) => {
    HandyScroll.EventBus.emit('update', { sourceElement: element.value })

    if (oldVal && oldVal?.length === newVal?.length) {
      const ids = oldVal.map((item) => item.id)
      const hasSameIds = newVal.every((item) => ids.includes(item.id))

      if (!hasSameIds) {
        clearFilterValues()
      }
    } else {
      clearFilterValues()
    }
  },
  { immediate: true }
)

watch(
  () => props.layout,
  () => {
    HandyScroll.EventBus.emit('update', { sourceElement: element.value })
  },
  { deep: true }
)

watch(
  [() => props.layout, () => props.attributes, freezeColumn],
  () => nextTick(generateFreezeColumnLeftPosition),
  {
    deep: true
  }
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

.cell-selected-border {
  outline: 2px solid var(--color-primary) !important;
  outline-offset: -2px;

  .freeze {
    border-bottom: 1px solid var(--color-primary) !important;
  }

  .freeze::before {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 2px;
    background-color: var(--color-primary);
  }

  .freeze::after {
    content: '';
    position: absolute;
    left: 0;
    bottom: 0;
    width: 100%;
    height: 1.5px;
    background-color: var(--color-primary);
  }
}

.freeze {
  left: 0;
  position: sticky;
  z-index: 10;
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
