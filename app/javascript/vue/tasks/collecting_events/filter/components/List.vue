<template>
  <div class="full_width">
    <table
      class="full_width"
      v-resize-column
    >
      <thead>
        <tr>
          <td colspan="5" />
          <th
            colspan="5"
            scope="colgroup"
          >
            Verbatim
          </th>
        </tr>
        <tr>
          <th>
            <input
              v-model="selectAll"
              type="checkbox"
            >
          </th>
          <th
            v-for="(label, property) in properties"
            :key="property"
            @click="sortTable(property)"
          >
            {{ label }}
          </th>
          <th>Options</th>
        </tr>
      </thead>
      <tbody @mouseout="$emit('onRowHover', undefined)">
        <tr
          v-for="item in list"
          :key="item.id"
          class="contextMenuCells"
          @mouseover="$emit('onRowHover', item)"
        >
          <td>
            <input
              v-model="idSelected"
              :value="item.id"
              type="checkbox"
            >
          </td>
          <td
            v-for="(_, property) in properties"
            :key="property"
            v-html="item[property]"
          />
          <td>
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
import { ref, computed } from 'vue'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn.js'
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

const emit = defineEmits([
  'onSort',
  'onRowHover',
  'update:modelValue'
])

const ascending = ref(false)

const properties = {
  id: 'ID',
  verbatim_locality: 'Locality',
  start_date: 'Date start',
  end_date: 'Date end',
  verbatim_collectors: 'Collectors',
  verbatim_method: 'Method',
  verbatim_trip_identifier: 'Trip Identifier',
  verbatim_latitude: 'Latitude',
  verbatim_longitude: 'Longitude',
  cached_level0_geographic_name: 'Level 1',
  cached_level1_geographic_name: 'Level 2',
  cached_level2_geographic_name: 'Level 3',
  georeferencesCount: 'Geo',
  identifiers: 'Identifiers',
  roles: 'Collectors'
}

const idSelected = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const selectAll = computed({
  get: () => idSelected.value.length === props.list.length,
  set: value => {
    idSelected.value = value
      ? props.list.map(item => item.id)
      : []
  }
})

const sortTable = (sortProperty) => {
  emit('onSort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}

</script>
<style scoped>
  td {
    max-width: 50px;
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
