<template>
  <div class="full_width">
    <table
      class="full_width"
      v-resize-column
    >
      <thead>
        <tr>
          <th @click="sortTable('cached')">Name</th>
          <th @click="sortTable('cached_author_year')">Author and year</th>
          <th @click="sortTable('original_combination')">Original combination</th>
          <th>Valid?</th>
          <th @click="sortTable('rank')">Rank</th>
          <th>Parent</th>
          <th>Options</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id">
          <td>
            <a
              :href="`/tasks/nomenclature/browse?taxon_name_id=${item.id}`"
              v-html="item.cached_html"/>
          </td>
          <td>{{ item.cached_author_year }}</td>
          <td v-html="item.original_combination" />
          <td>{{ item.cached_is_valid }}</td>
          <td>{{ item.rank }}</td>
          <td>
            <a
              :href="`/tasks/nomenclature/browse?taxon_name_id=${item.parent.id}`"
              v-html="item.parent.object_label"/>
          </td>
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
import { vResizeColumn } from 'directives/resizeColumn'

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

  directives: {
    ResizeColumn: vResizeColumn
  },

  emits: ['onSort'],

  data () {
    return {
      ascending: false
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
