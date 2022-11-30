<template>
  <HandyScroll ref="root">
    <div>
      <table
        ref="tableBar"
        v-resize-column
      >
        <thead>
          <tr>
            <th>
              <input
                type="checkbox"
                v-model="selectIds"
              >
            </th>
            <th>Collection object</th>
            <template
              v-for="(item, index) in list.column_headers"
              :key="item"
            >
              <th
                v-if="index > 2"
                @click="sortTable(index)"
              >
                {{ item }}
              </th>
            </template>
          </tr>
        </thead>
        <tbody>
          <tr
            class="contextMenuCells"
            :class="{ even: indexR % 2 }"
            v-for="(row, indexR) in list.data"
            :key="row[0]"
          >
            <td>
              <input
                v-model="ids"
                :value="row[0]"
                type="checkbox"
              >
            </td>
            <td>
              <a
                :href="`/tasks/collection_objects/browse?collection_object_id=${row[0]}`"
                target="_blank"
              >
                Show
              </a>
            </td>
            <template
              v-for="(item, index) in row"
              :key="index"
            >
              <td v-if="index > 2">
                <span>{{ item }}</span>
              </td>
            </template>
          </tr>
        </tbody>
      </table>
    </div>
  </HandyScroll>
</template>

<script setup>
import { computed, watch, ref } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn.js'
import HandyScroll from 'vue-handy-scroll'

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

const root = ref(null)

const ids = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

const selectIds = computed({
  get: () => props.list?.data?.length === ids.value.length,
  set: value => {
    ids.value = value
      ? props.list.data.map(r => r[0])
      : []
  }
})

const ascending = ref(false)

watch(
  () => props.list,
  () => {
    HandyScroll.EventBus.emit('update', { sourceElement: root.value })
  })

const sortTable = (sortProperty) => {
  emit('onSort', sortArray(props.list.data, sortProperty, ascending.value))
  ascending.value = !ascending.value
}
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

  td {
    max-width: 80px;
    overflow : hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  td:hover {
    max-width : 200px;
    text-overflow: ellipsis;
    white-space: normal;
  }
</style>
