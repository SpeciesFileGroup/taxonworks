<template>
  <div class="full_width">
    <table class="full_width">
      <thead>
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
          @mouseover="$emit('onRowHover', item)">
          <td
            v-for="(value, property) in properties"
            :key="property"
            v-html="item[property]"/>
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

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },
  props: {
    list: {
      type: Array,
      default: () => ([])
    }
  },
  data () {
    return {
      ascending: false,
      properties: {
        id: 'ID',
        name: 'Name',
        verbatim_locality: 'Verbatim locality',
        date_start_string: 'Date start',
        cached_level0_geographic_name: 'Level 1',
        cached_level1_geographic_name: 'Level 2',
        cached_level2_geographic_name: 'Level 3',
        georeferencesCount: 'Points'

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
  tr:hover {
    background-color: #BBDDBB
  }
</style>