<template>
  <div class="full_width">
    <table
      class="full_width"
      v-resize-column
    >
      <thead>
        <tr>
          <th>
            <input
              type="checkbox"
              v-model="selectAll"
            >
          </th>
          <th @click="sortTable('cached')">
            Name
          </th>
          <th @click="sortTable('cached_author_year')">
            Author and year
          </th>
          <th @click="sortTable('original_combination')">
            Original combination
          </th>
          <th>Valid?</th>
          <th @click="sortTable('rank')">
            Rank
          </th>
          <th>Parent</th>
          <th>Options</th>
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
              v-model="selectedIds"
              :value="item.id"
              type="checkbox"
            >
          </td>
          <td>
            <a
              :href="`/tasks/nomenclature/browse?taxon_name_id=${item.id}`"
              v-html="item.cached_html"
            />
          </td>
          <td>{{ item.cached_author_year }}</td>
          <td v-html="item.original_combination" />
          <td>{{ item.cached_is_valid }}</td>
          <td>{{ item.rank }}</td>
          <td>
            <a
              v-if="item.parent"
              :href="`/tasks/nomenclature/browse?taxon_name_id=${item.parent.id}`"
              v-html="item.parent.object_label"
            />
          </td>
          <td class="options-column">
            <div class="horizontal-left-content">
              <radial-object :global-id="item.global_id" />
              <radial-annotator
                type="annotations"
                :global-id="item.global_id"
              />
            </div>
          </td>
        </tr>
      </tbody>
    </table>

    <span
      v-if="list.length"
      class="horizontal-left-content"
    >
      {{ list.length }} records.
    </span>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'

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

const selectedIds = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const emit = defineEmits(['onSort', 'update:modelValue'])
const ascending = ref(false)

const selectAll = computed({
  get: () => props.modelValue.length === props.list.length,
  set: value => {
    selectedIds.value = value
      ? props.list.map(item => item.id)
      : []
  }
})

function sortTable (sortProperty) {
  emit('onSort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}
</script>

<style lang="scss" scoped>
  .options-column {
    width: 130px;
  }
</style>
