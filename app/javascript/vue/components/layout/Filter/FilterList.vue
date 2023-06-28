<template>
  <HandyScroll>
    <table
      class="full_width"
      v-resize-column
      ref="element"
    >
      <thead>
        <tr v-if="headerGroups.length || dataAttributeHeaders.length">
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
          <td
            v-if="!headerGroups.length"
            :colspan="Object.keys(attributes).length + 2"
          />

          <th
            v-if="dataAttributeHeaders.length"
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
            {{ title }}
          </th>
          <template v-if="dataAttributeHeaders.length">
            <th
              v-for="header in dataAttributeHeaders"
              :key="header"
              scope="colgroup"
              class="cell-left-border"
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
          :class="{ even: index % 2 }"
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
            <div class="horizontal-right-content">
              <RadialAnnotator :global-id="item.global_id" />
              <RadialObject
                v-if="radialObject"
                :global-id="item.global_id"
              />
              <RadialNavigation :global-id="item.global_id" />
            </div>
          </td>
          <td
            v-for="(_, attr) in attributes"
            :key="attr"
            v-html="item[attr]"
          />
          <td
            v-for="(predicateName, dIndex) in dataAttributeHeaders"
            :key="predicateName"
            :class="{ 'cell-left-border': dIndex === 0 }"
            v-text="item.data_attributes[predicateName]"
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
import HandyScroll from 'vue-handy-scroll'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/object/radial.vue'

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
    required: true
  },

  headerGroups: {
    type: Array,
    default: () => []
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
</script>
