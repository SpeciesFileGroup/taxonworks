<template>
  <table>
    <tr>
      <th @click="sortTable('pages')">Pages</th>
      <th>Is original</th>
      <th @click="sortTable('citation_object.object_tag')">Name</th>
      <th>Type</th>
      <th>Radial</th>
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
  import SortArray from 'helpers/sortArray'

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
      sortTable (sortProperty) {
        this.list = SortArray(sortProperty, this.list, this.ascending)
        this.ascending = !this.ascending
      }
    }
  }
</script>
