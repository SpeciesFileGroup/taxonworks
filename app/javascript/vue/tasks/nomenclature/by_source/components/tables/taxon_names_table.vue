<template>
  <table>
    <tr>
      <th @click="sortPages()">
        Pages
      </th>
      <th>Is original</th>
      <th @click="sortTable('citation_object.object_tag')">
        Name
      </th>
      <th>Confidence</th>
      <th>Radial</th>
      <th>Delete</th>
    </tr>
    <taxon-names-row
      v-for="item in list"
      :key="item.id"
      @delete="removeCitation"
      :citation="item"
    />
  </table>
</template>

<script>

import TaxonNamesRow from './taxon_names_row.vue'
import extendedTables from './extendedTable'

export default {
  mixins: [extendedTables],
  components: {
    TaxonNamesRow
  }
}
</script>
