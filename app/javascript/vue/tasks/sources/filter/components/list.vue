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
          <th>
            <input
              type="checkbox"
              v-model="toggleIds"
            >
          </th>
          <th />
          <th
            v-for="item in sort"
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
            >
          </td>
          <td>
            <div class="horizontal-left-content">
              <AddToProject
                :id="item.id"
                :project-source-id="item.project_source_id"
              />
              <PinComponent
                class="button button-circle"
                :object-id="item.id"
                type="Source"
              />
              <RadialAnnotator :global-id="item.global_id" />
              <RadialNavigation :global-id="item.global_id" />
            </div>
          </td>
          <td>
            <span>{{ item.id }}</span>
          </td>
          <td>
            <span v-html="item.cached" />
          </td>
          <td>
            <span>{{ item.year }}</span>
          </td>
          <td>
            <span>{{ item.type }}</span>
          </td>
          <td>
            <div class="flex-wrap-row">
              <pdf-button
                v-for="pdf in item.documents"
                :key="pdf.id"
                :pdf="pdf"
              />
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>

import RadialNavigation from 'components/radials/navigation/radial'
import RadialAnnotator from 'components/radials/annotator/annotator'
import PdfButton from 'components/pdfButton'
import AddToProject from 'components/addToProjectSource'
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn'
import { computed, ref } from 'vue'

const sort = ['id', 'cached', 'year', 'type', 'documents']

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

const emit = defineEmits([
  'update:modelValue',
  'onSort'
])

const ids = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const toggleIds = computed({
  get: () => props.list.length === props.modelValue.length,
  set: value => emit('update:modelValue',
    value
      ? props.list.map(item => item.id)
      : []
  )
})

const ascending = ref(false)

const sortTable = sortProperty => {
  emit('onSort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}
</script>
