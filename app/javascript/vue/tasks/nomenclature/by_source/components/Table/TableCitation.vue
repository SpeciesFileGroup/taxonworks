<template>
  <table>
    <thead>
      <tr>
        <th @click="sortColumn('pages')">Pages</th>
        <th>Is original</th>
        <th @click="sortColumn('citation_object.object_label')">Object</th>
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
import { ActionNames } from '../../store/actions/actions'
import { ref } from 'vue'
import { useStore } from 'vuex'

const props = defineProps({
  list: {
    type: Array,
    required: true
  },

  type: {
    type: String,
    required: true
  }
})

const store = useStore()
const asc = ref(false)

const sortColumn = (property) => {
  store.dispatch(ActionNames.SortCitationList, { 
    type: props.type, 
    ascending: asc.value,
    property
  })

  asc.value = !asc.value
}
</script>