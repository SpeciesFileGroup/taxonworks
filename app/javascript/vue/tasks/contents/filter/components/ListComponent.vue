<template>
  <div
    v-if="list.length"
    class="full_width"
  >
    <table
      class="full_width table-striped"
      v-resize-column
    >
      <thead>
        <tr>
          <th class="w-2">
            <input
              type="checkbox"
              v-model="toggleIds"
            />
          </th>
          <th class="w-2" />
          <th
            v-for="item in Object.keys(attributes)"
            :key="item"
            class="capitalize"
            @click="sortTable(item)"
          >
            {{ item }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          class="contextMenuCells"
          v-for="item in list"
          :key="item.id"
        >
          <td>
            <input
              v-model="ids"
              :value="item.id"
              type="checkbox"
            />
          </td>
          <td>
            <div class="horizontal-left-content">
              <RadialAnnotator :global-id="item.global_id" />
              <RadialNavigation :global-id="item.global_id" />
            </div>
          </td>
          <td
            v-for="(renderFunction, key) in attributes"
            :key="key"
            v-html="renderFunction(item)"
          />
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import RadialNavigation from 'components/radials/navigation/radial'
import RadialAnnotator from 'components/radials/annotator/annotator'
import { marked } from 'marked'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn'
import { computed, ref } from 'vue'

const attributes = {
  otu: (item) => item.otu.object_tag,
  topic: (item) => item.topic.object_tag,
  text: (item) => marked.parse(item.text)
}

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'onSort'])

const ids = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const toggleIds = computed({
  get: () => props.list.length === props.modelValue.length,
  set: (value) =>
    emit('update:modelValue', value ? props.list.map((item) => item.id) : [])
})

const ascending = ref(false)

const sortTable = (sortProperty) => {
  emit('onSort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}
</script>
