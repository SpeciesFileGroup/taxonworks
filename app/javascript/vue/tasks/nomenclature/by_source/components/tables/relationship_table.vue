<template>
  <table>
    <tr>
      <th @click="sortPages()">Pages</th>
      <th>Is original</th>
      <th @click="sortTable('citation_object.object_tag')">Object</th>
      <th>Radial</th>
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
import extendedTables from './extendedTable'

export default {
  mixins: [extendedTables],
  components: {
    RowComponents
  }
}
</script>
