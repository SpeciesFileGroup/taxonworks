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
            <th>ID</th>
            <th>First name</th>
            <th>Last name</th>
            <th>Prefix</th>
            <th>Suffix</th>
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
                type="checkbox"
              >
            </td>
            <td>{{ item.id }}</td>
            <td v-html="item.first_name" />
            <td v-html="item.last_name" />
            <td v-html="item.prefix" />
            <td v-html="item.suffix" />
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

import { computed, ref, watch } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import HandyScroll from 'vue-handy-scroll'
import { vResizeColumn } from 'directives/resizeColumn.js'
import RadialNavigation from 'components/radials/navigation/radial.vue'

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
