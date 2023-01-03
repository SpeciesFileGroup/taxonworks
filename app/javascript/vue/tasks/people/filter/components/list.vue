<template>
  <HandyScroll>
    <div ref="element">
      <table
        class="full_width table-striped"
        v-resize-column
      >
        <thead>
          <tr>
            <th class="w-2">
              <input
                v-model="selectIds"
                type="checkbox"
              >
            </th>
            <th class="w-2" />
            <th>First name</th>
            <th>Prefix</th>
            <th>Last name</th>
            <th>Suffix</th>
            <th>ID</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in list"
            :key="item.id"
            class="contextMenuCells"
          >
            <td>
              <input
                v-model="ids"
                :value="item.id"
                type="checkbox"
              >
            </td>
            <td>
              <div class="horizontal-left-content">
                <RadialAnnotator :global-id="item.global_id" />
                <RadialNavigation :global-id="item.global_id" />
              </div>
            </td>
            <td v-html="item.first_name" />
            <td v-html="item.prefix" />
            <td v-html="item.last_name" />
            <td v-html="item.suffix" />
            <td>{{ item.id }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </HandyScroll>
</template>

<script setup>

import { computed, ref, watch } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn.js'
import HandyScroll from 'vue-handy-scroll'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
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
