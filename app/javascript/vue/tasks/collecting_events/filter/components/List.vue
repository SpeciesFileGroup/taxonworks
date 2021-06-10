<template>
  <div class="full_width">
    <table class="full_width">
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
            {{ property }}
          </th>
          <th>Identifiers</th>
          <th>Collectors</th>
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
            v-for="(param, property) in properties"
            :key="property"
            v-html="printValue(param, item)"/>
          <td>
            {{ printIdentifiers(item.identifiers) }}
          </td>
          <td>
            {{ printCollectors(item.collector_roles) }}
          </td>
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

const printDate = (date) => date.filter(date => date).join('/')

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },
  props: {
    list: {
      type: Array,
      default: () => []
    }
  },

  emits: ['onSort'],

  data () {
    return {
      ascending: false,
      properties: {
        ID: 'id',
        Locality: 'verbatim_locality',
        'Date start': {
          printValue: ce => printDate([ce.start_date_day, ce.start_date_month, ce.start_date_year])
        },
        'Date end': {
          printValue: ce => printDate([ce.end_date_day, ce.end_date_month, ce.end_date_year])
        },
        Collectors: 'verbatim_collectors',
        Method: 'verbatim_method',
        'Trip Identifier': 'verbatim_trip_identifier',
        Latitude: 'verbatim_latitude',
        Longitude: 'verbatim_longitude',
        'Level 1': 'cached_level0_geographic_name',
        'Level 2': 'cached_level1_geographic_name',
        'Level 3': 'cached_level2_geographic_name',
        Geo: 'georeferencesCount'

      }
    }
  },

  methods: {
    sortTable (sortProperty) {
      this.$emit('onSort', sortArray(this.list, sortProperty, this.ascending))
      this.ascending = !this.ascending
    },

    printCollectors (roles = []) {
      return roles.map(role => role.person.object_tag).join('; ')
    },

    printIdentifiers (identifiers = []) {
      return identifiers.map(identifier => identifier.cached).join('; ')
    },

    printValue (data, ce) {
      return (typeof data === 'string')
        ? ce[data]
        : data.printValue(ce)
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
