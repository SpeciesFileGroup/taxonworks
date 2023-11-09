<template>
  <HandyScroll>
    <table
      class="full_width"
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
          <td colspan="2" />
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
            Data attributes
          </th>
        </tr>
        <tr>
          <th class="w-2">
            <input
              v-model="selectIds"
              :disabled="!list.length"
              type="checkbox"
            />
          </th>
          <th class="w-2" />
          <th
            v-for="(title, attr) in attributes"
            :key="attr"
            @click="sortTable(attr)"
          >
            <div class="horizontal-left-content">
              <span>{{ title }}</span>
              <VBtn
                v-if="filterValues[attr]"
                class="margin-small-left"
                color="primary"
                small
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
              :class="{ 'cell-left-border': pIndex === 0 }"
              @click="sortTable(`${key}.${property}`)"
            >
              <div class="horizontal-left-content">
                <span>{{ property }}</span>
                <VBtn
                  v-if="filterValues[`${key}.${property}`]"
                  class="margin-small-left"
                  color="primary"
                  small
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
          class="contextMenuCells"
          :class="{
            even: index % 2,
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
          <td>
            <div class="horizontal-right-content gap-small">
              <slot
                name="buttons-left"
                :item="item"
              />
              <RadialAnnotator
                :global-id="item.global_id"
                @click="() => (lastRadialOpenedRow = item.id)"
              />
              <RadialObject
                v-if="radialObject"
                :global-id="item.global_id"
                @click="() => (lastRadialOpenedRow = item.id)"
              />
              <RadialNavigation
                :global-id="item.global_id"
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
                v-html="item[attr]"
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
              :class="{ 'cell-left-border': pIndex === 0 }"
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
import { computed, ref, watch } from 'vue'
import { sortArray } from '@/helpers/arrays.js'
import { vResizeColumn } from '@/directives/resizeColumn.js'
import { humanize } from '@/helpers/strings'
import VBtn from '@/components/ui/VBtn/index.vue'
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
  }
})

const emit = defineEmits([
  'onSort',
  'update:modelValue',
  'mouseover:row',
  'mouseout:body'
])

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
    return Array.isArray(acc) ? acc.map((item) => item[curr]) : acc[curr]
  }, item)
}

watch(
  () => props.list,
  () => {
    HandyScroll.EventBus.emit('update', { sourceElement: element.value })
  },
  { immediate: true }
)

function sortTable(sortProperty) {
  emit('onSort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}

function scrollToTop() {
  window.scrollTo(0, 0)
}
</script>

<style scoped>
.cell-left-border {
  border-left: 3px #eaeaea solid;
}

.cell-selected-border {
  outline: 2px solid var(--color-primary) !important;
  outline-offset: -2px;
}
</style>
