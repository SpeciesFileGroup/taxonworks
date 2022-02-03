<template>
  <HandyScroll>
    <div ref="element">
      <table
        class="full_width"
        v-resize-column
      >
        <thead>
          <tr>
            <th />
            <th>ID</th>
            <th>Extract</th>
            <th>Year</th>
            <th>Month</th>
            <th>Day</th>
            <th />
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
                type="checkbox">
            </td>
            <td>{{ item.id }}</td>
            <td v-html="item.object_tag" />
            <td>{{ item.year_made }}</td>
            <td>{{ item.month_made }}</td>
            <td>{{ item.day_made }}</td>
            <td />
          </tr>
        </tbody>
      </table>
    </div>
  </HandyScroll>
</template>

<script setup>

import { ref, watch } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import HandyScroll from 'vue-handy-scroll'
import { vResizeColumn } from 'directives/resizeColumn.js'

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

watch(
  () => props.list,
  () => { HandyScroll.EventBus.emit('update', { sourceElement: element.value }) },
  { immediate: true }
)

const ascending = ref(false)

const sortTable = sortProperty => {
  emit('onSort', sortArray(this.list, sortProperty, ascending.value))
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

</style>
