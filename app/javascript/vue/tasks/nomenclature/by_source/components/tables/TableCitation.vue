<template>
  <table>
    <thead>
      <tr>
        <th>Pages</th>
        <th>Is original</th>
        <th>Object</th>
        <th/>
      </tr>
    </thead>
    <tbody>
      <template
        v-for="citation in list"
        :key="citation.id">
        <component 
          :is="citation.citation_object_type === TAXON_NAME
            ? TableCitationTaxonRow
            : TableCitationRow
          " 
          :citation="citation"
        />
      </template>
    </tbody>
  </table>
</template>

<script setup>
import TableCitationRow from './TableCitationRow.vue'
import TableCitationTaxonRow from './TableCitationTaxonRow.vue'
import { TAXON_NAME } from 'constants/index.js'

defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>