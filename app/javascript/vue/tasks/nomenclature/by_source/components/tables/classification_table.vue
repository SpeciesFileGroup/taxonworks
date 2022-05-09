<template>
  <table>
    <tr>
      <th @click="sortPages()">Pages</th>
      <th>Is original</th>
      <th @click="sortTable('citation_object.object_tag')">Object</th>
      <th />
    </tr>
    <row-components
      v-for="item in list"
      :key="item.id"
      :citation="item"
      @delete="removeCitation"
    />
  </table>
</template>

<script>

import RowComponents from './taxon_name_classification_row'
import extendedTables from './extendedTable'

export default {
  mixins: [extendedTables],
  components: {
    RowComponents
  }
}
</script>