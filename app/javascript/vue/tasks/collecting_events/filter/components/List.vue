<template>
  <div class="full_width">
    <table
      class="full_width"
      v-resize-column
    >
      <thead>
        <tr>
          <td colspan="4"/>
          <th colspan="5" scope="colgroup">Verbatim</th>
        </tr>
        <tr>
          <th
            v-for="(label, property) in properties"
            :key="property"
            @click="sortTable(property)">
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
          @mouseover="$emit('onRowHover', item)">
          <td
            v-for="(_, property) in properties"
            :key="property"
            v-html="item[property]"
          />
          <td>
            <div class="horizontal-left-content">
              <radial-object :global-id="item.global_id"/>
              <radial-annotator
                type="annotations"
                :global-id="item.global_id"/>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <span
      v-if="list.length"
      class="horizontal-left-content">{{ list.length }} records.
    </span>
  </div>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import { sortArray } from 'helpers/arrays.js'
import { vResizeColumn } from 'directives/resizeColumn.js'

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },

  directives: {
    ResizeColumn: vResizeColumn
  },

  props: {
    list: {
      type: Array,
      default: () => []
    }
  },

  emits: [
    'onSort',
    'onRowHover'
  ],

  data () {
    return {
      ascending: false,
      properties: {
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
    }
  },

  methods: {
    sortTable (sortProperty) {
      this.$emit('onSort', sortArray(this.list, sortProperty, this.ascending))
      this.ascending = !this.ascending
    }
  }
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
