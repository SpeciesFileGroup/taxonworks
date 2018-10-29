<template>
  <table>
    <tr>
      <th @click="sortByPages">Pages</th>
      <th>Is original</th>
      <th>Object</th>
      <th>Radial</th>
      <th>Otu</th>
      <th>Delete</th>
    </tr>
    <row-components 
      v-for="item in list"
      :key="item.id"
      @delete="removeCitation"
      :citation="item"/>
  </table>  
</template>

<script>

import RowComponents from './taxon_name_relationship_row'

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
    },
    sortByPages() {
      function compare(a,b) {
        if (a.pages < b.pages)
          return -1;
        if (a.pages > b.pages)
          return 1;
        return 0;
      }

      this.list.sort(compare);      
    }
  }
}
</script>