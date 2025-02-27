<template>
  <HandyScroll>
    <table
      class="table-striped table-cell-border table-header-border full_width"
      v-resize-column
      ref="element"
    >
      <thead>
        <tr
          v-if="
            headerGroups.length ||
            dataAttributeHeaders.length ||
            layout?.properties
          "
        >
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
            <th
              v-if="properties.length"
              :colspan="properties.length"
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

          <th
            v-if="
              dataAttributeHeaders.length &&
              (!isLayoutConfig || layout.includes.data_attributes)
            "
            :colspan="dataAttributeHeaders.length"
            scope="colgroup"
            class="cell-left-border"
          >
            7 Data attributes
          </th>
        </tr>

        <tr>
          <td
            class="header-empty-td"
            :colspan="
              radialObject || radialAnnotator || radialNavigator ? 2 : 1
            "
          />

          <th
            v-for="(title, attr) in attributes"
            :key="attr"
            :class="['cursor-pointer', { freeze: freezeColumn.includes(attr) }]"
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
            <th
              v-for="(property, pIndex) in propertiesList"
              :key="property"
              :class="[
                {
                  'cell-left-border': pIndex === 0,
                  freeze: freezeColumn.includes(`${key}.${property}`)
                },
                'cursor-pointer'
              ]"
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
        </tr>

        <tr class="header-row-attributes">
          <th class="w-2">
            <input
              v-model="selectIds"
              :disabled="!list.length"
              type="checkbox"
            />
          </th>
          <th
            v-if="radialObject || radialAnnotator || radialNavigator"
            class="w-2"
          />
          <th
            v-for="(title, attr) in attributes"
            :key="attr"
            :class="['cursor-pointer', { freeze: freezeColumn.includes(attr) }]"
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
            <th
              v-for="(property, pIndex) in propertiesList"
              :key="property"
              :class="[
                {
                  'cell-left-border': pIndex === 0,
                  freeze: freezeColumn.includes(`${key}.${property}`)
                },
                'cursor-pointer'
              ]"
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

          <template
            v-if="
              dataAttributeHeaders.length &&
              (!isLayoutConfig || layout.includes.data_attributes)
            "
          >
            <th
              v-for="(header, index) in dataAttributeHeaders"
              :key="header"
              scope="colgroup"
              :class="{ 'cell-left-border': index === 0 }"
              @click="sortTable(`data_attributes.${header}`)"
            >
              {{ header }}
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
          v-show="rowHasCurrentValues(item)"
          @mouseover="() => emit('mouseover:row', { index, item })"
        >
          <td>
            <input
              v-model="ids"
              :value="item.id"
              type="checkbox"
            />
          </td>
          <td v-if="radialObject || radialAnnotator || radialNavigator">
            <div class="horizontal-right-content gap-small">
              <slot
                name="buttons-left"
                :item="item"
              />
              <RadialAnnotator
                v-if="radialAnnotator"
                :global-id="item.global_id"
                reload
                @click="() => (lastRadialOpenedRow = item.id)"
              />
              <RadialObject
                v-if="radialObject"
                :global-id="item.global_id"
                @click="() => (lastRadialOpenedRow = item.id)"
              />
              <RadialNavigation
                v-if="radialNavigator"
                :global-id="item.global_id"
                :redirect="false"
                @delete="emit('remove', { item, index })"
                @click="() => (lastRadialOpenedRow = item.id)"
              />
            </div>
          </td>
          <template v-if="attributes">
            <slot
              v-for="(_, attr) in attributes"
              :key="attr"
              :name="attr"
              :value="item[attr]"
            >
              <td
                :class="{ freeze: freezeColumn.includes(attr) }"
                v-html="item[attr]"
                :data-td-column="attr"
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
              />
            </slot>
          </template>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <td
              v-for="(property, pIndex) in properties"
              :key="property"
              v-html="renderItem(item, key, property)"
              :data-td-column="`${key}.${property}`"
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
                  filterValues[`${key}.${property}`] = Array.isArray(item[key])
                    ? item[key].map((obj) => obj[property])
                    : item[key][property]
                }
              "
            />
          </template>

          <template
            v-if="
              dataAttributeHeaders.length &&
              (!isLayoutConfig || layout.includes.data_attributes)
            "
          >
            <td
              v-for="(predicateName, dIndex) in dataAttributeHeaders"
              :key="predicateName"
              :class="{ 'cell-left-border': dIndex === 0 }"
              v-text="item.data_attributes[predicateName]"
            />
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

const dataAttributeHeaders = computed(() => {
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

function getValue(item, property) {
  const properties = property.split('.')

  return properties.reduce((acc, curr) => {
    return Array.isArray(acc) ? acc.map((item) => item?.[curr]) : acc?.[curr]
  }, item)
}

function sortTable(sortProperty) {
  emit('onSort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}

function scrollToTop() {
  window.scrollTo(0, 0)
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
  () => {
    HandyScroll.EventBus.emit('update', { sourceElement: element.value })
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
</script>

<style scoped>
table {
  border-collapse: separate;
}
.cell-left-border {
  border-left: 3px #eaeaea solid;
}

.cell-selected-border {
  outline: 2px solid var(--color-primary) !important;
  outline-offset: -2px;
}

.freeze {
  left: 0;
  position: sticky;
  z-index: 10;
}

.header-empty-td {
  background: #f8f8f8 !important;
  border-bottom: 0;
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
