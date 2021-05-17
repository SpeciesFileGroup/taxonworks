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
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id">
          <td
            v-for="(value, property) in properties"
            :key="property"
            v-html="item[property]"/>
          <td class="options-column">
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
        cached_level2_geographic_name: 'Level 3'

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

<style lang="scss" scoped>
  table {
    margin-top: 0px;
  }
  tr {
    height: 44px;
  }
  .options-column {
    width: 130px;
  }
</style>
