<template>
  <div
    v-if="list"
    class="full_width">
    <table class="full_width">
      <thead>
        <tr>
          <th>Collection object</th>
          <template
            v-for="(item, index) in list.column_headers">
            <th
              v-if="index > 2"
              @click="sortTable(item)">{{item}}
            </th>
          </template>
        </tr>
      </thead>
      <tbody>
        <tr
          class="contextMenuCells"
          :class="{ even: indexR % 2 }"
          v-for="(row, indexR) in list.data"
          :key="row[0]">
          <td>
            <a
              :href="`/collection_objects/${row[0]}`"
              target="_blank">
              Show
            </a>
          </td>
          <template v-for="(item, index) in row">
            <td v-if="index > 2">
              <span>{{item}}</span>
            </td>
          </template>
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

import RadialAnnotator from 'components/annotator/annotator'
import RadialObject from 'components/radial_object/radialObject'

export default {
  props: {
    list: {
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      ascending: false
    }
  },
  methods: {
    sortTable (sortProperty) {
      function compare (a,b) {
        if (a[sortProperty] < b[sortProperty])
          return (this.ascending ? -1 : 1)
        if (a[sortProperty] > b[sortProperty])
          return (this.ascending ? 1 : -1)
        return 0
      }
      this.list.data.sort(compare)
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
