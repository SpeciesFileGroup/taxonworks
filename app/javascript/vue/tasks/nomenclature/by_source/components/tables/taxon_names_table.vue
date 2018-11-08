<template>
  <table>
    <tr>
      <th @click="sortByPages">Pages</th>
      <th>Is original</th>
      <th>Name</th>
      <th>Type</th>
      <th>Radial</th>
      <th>Otu</th>
      <th>Delete</th>
    </tr>
    <taxon-names-row
      v-for="item in list"
      :key="item.id"
      @delete="removeCitation"
      :citation="item"/>
  </table>
</template>

<script>

  import TaxonNamesRow from './taxon_names_row.vue'

  export default {
    components: {
      TaxonNamesRow
    },
    props: {
      list: {
        type: Array,
        required: true
      },
      names: {
        type: Array,
        required: true
      }
    },
    methods: {
      removeCitation(citation) {
        let index = this.list.findIndex((item) => {
          return citation.id == item.id
        })
        if (index > -1) {
          this.list.splice(index, 1)
        }
      },
      sortByPages() {
        function compare(a, b) {
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
