<template>
  <HandyScroll>
    <div ref="element">
      <table
        class="full_width"
        v-resize-column
      >
        <thead>
          <tr>
            <th>
              <input
                v-model="selectIds"
                type="checkbox"
              >
            </th>
            <th v-for="label in TABLE_HEADERS">
              {{ label }}
            </th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in makeExtractList(list)"
            :key="item.id"
            class="contextMenuCells"
            :class="{ even: index % 2 }"
          >
            <td>
              <input
                v-model="ids"
                :value="item.id"
                type="checkbox"
              >
            </td>
            <td
              v-for="attr in TABLE_ATTRIBUTES"
              :key="attr"
              v-html="item[attr]"
            />
            <td>
              <radial-navigation
                :global-id="item.global_id"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </HandyScroll>
</template>

<script setup>
import HandyScroll from 'vue-handy-scroll'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import makeExtractList from 'tasks/extracts/new_extract/helpers/makeExtractList'
import { computed, ref, watch } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn.js'
import {
  TABLE_ATTRIBUTES,
  TABLE_HEADERS
} from 'tasks/extracts/new_extract/const/table.js'

const props = defineProps({
  list: {
    type: Object,
    default: undefined
  },
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'onSort',
  'update:modelValue'
])

const element = ref(null)

const selectIds = computed({
  get: () => props.list.length === props.modelValue.length,
  set: value => emit('update:modelValue',
    value
      ? props.list.map(item => item.id)
      : []
  )
})

const ids = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  () => props.list,
  () => { HandyScroll.EventBus.emit('update', { sourceElement: element.value }) },
  { immediate: true }
)

delete TABLE_ATTRIBUTES.global_id
</script>

<style lang="scss" scoped>

  tr {
    height: 44px;
  }
  .options-column {
    width: 130px;
  }
  .overflow-scroll {
    overflow: scroll;
  }

</style>
