<template>
  <div
    v-if="list"
    class="full_width">
    <table class="full_width">
      <thead>
        <tr>
          <th
            v-for="item in list.column_headers"
            @click="sortTable(item)">{{item}}</th>
        </tr>
      </thead>
      <tbody>
        <tr
          class="contextMenuCells"
          :class="{ even: index % 2 }"
          v-for="(row, index) in list.data"
          :key="row[0]">
          <td v-for="(item, index) in row">
            <a
              v-if="index === 0"
              :href="`/collection_objects/${item}`"
              target="_blank">
              {{ item }}
            </a>
            <span v-else>{{item}}</span>
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
