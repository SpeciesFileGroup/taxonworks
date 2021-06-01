<template>
  <div class="full_width">
    <table class="full_width">
      <thead>
        <tr>
          <th
            :class="classSort('object_tag')"
            @click="sortTable('object_tag')">Object tag</th>
          <th>Citations</th>
          <th>Options</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id">
          <td>
            <span v-html="item.object_tag"/>
          </td> 
          <td>
            <template v-for="citation in item.citations">
              <span :key="citation.id">{{ citation.citation_source_body }};</span>
            </template>
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

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },
  props: {
    list: {
      type: Array,
      default: () => { return [] }
    }
  },
  data() {
    return {
      sortColumns: {
        name: undefined,
        verbatim_author: undefined,
        year_of_publication: undefined,
        rank: undefined,
        original_combination: undefined
      }
    }
  },
  methods: {
    sortTable(sortProperty) {
      let that = this
      function compare(a,b) {
        if (a[sortProperty] < b[sortProperty])
          return (that.sortColumns[sortProperty] ? -1 : 1)
        if (a[sortProperty] > b[sortProperty])
          return (that.sortColumns[sortProperty] ? 1 : -1);
        return 0
      }
      if(this.sortColumns[sortProperty] == undefined) {
        this.sortColumns[sortProperty] = true
      }
      else {
        this.sortColumns[sortProperty] = !this.sortColumns[sortProperty]
      }
      this.list.sort(compare);      
    },
    classSort(value) {
      if(this.sortColumns[value] == true) { return 'headerSortDown' }
      if(this.sortColumns[value] == false) { return 'headerSortUp' }
      return ''
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
