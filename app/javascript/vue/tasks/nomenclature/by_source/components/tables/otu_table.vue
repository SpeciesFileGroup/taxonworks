<template>
  <table>
    <tr>
      <th @click="sortTable('object_tag')">Otu</th>
      <th>Radial</th>
      <th>Otu</th>
      <th>Otu navigator</th>
    </tr>
    <otu-row-component
      v-for="item in list"
      :key="item.id"
      :otu="item"/>
  </table>
</template>

<script>

import OtuRowComponent from './otu_row_component'
import SortArray from 'helpers/sortArray'

export default {
  components: {
    OtuRowComponent
  },

  props: {
    list: {
      type: Array,
      required: true
    }
  },

  data () {
    return {
      ascending: true
    }
  },

  methods: {
    sortTable (sortProperty) {
      this.list = SortArray(sortProperty, this.list, this.ascending)
      this.ascending = !this.ascending
    }
  }
}
</script>
