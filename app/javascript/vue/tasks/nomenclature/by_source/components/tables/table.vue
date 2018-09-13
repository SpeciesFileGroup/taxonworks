<template>
  <table>
    <tr>
      <th>Pages</th>
      <th>Object</th>
      <th>Radial</th>
      <th>Otu</th>
    </tr>
    <row-components 
      v-for="item in list"
      @delete="removeCitation"
      :citation="item"/>
  </table>  
</template>

<script>

import RowComponents from './row_components'

export default {
  components: {
    RowComponents
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  },
  methods: {
    removeCitation(citation) {
      let index = this.list.findIndex((item) => { return citation.id == item.id })
      if(index > -1) {
        this.list.splice(index, 1)
      }
    }
  }
}
</script>
