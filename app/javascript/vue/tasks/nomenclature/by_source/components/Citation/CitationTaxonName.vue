<template>
  <div>
    <VSpinner v-if="isLoading" />
    <div class="flex-separate middle">
      <h2>Taxon names</h2>
      <button
        @click="loadOtuByProxy('taxon_name_ids')"
        :disabled="!citations.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <TaxonNameTable :list="citations" />
  </div>
</template>
<script setup>

import TaxonNameTable from '../tables/taxon_names_table.vue'
import VSpinner from 'components/spinner.vue'
import useCitation from '../../composable/useCitation.js'
import { TAXON_NAME } from 'constants/index.js'
import { watch } from 'vue'

const props = defineProps({
  sourceId: {
    type: String,
    default: undefined
  },
})

const { 
  isLoading,
  citations,
  requestCitations,
  loadOtuByProxy,
  pagination
} = useCitation(TAXON_NAME)

watch(
  () => props.sourceId, 
  id => {
    requestCitations({
      sourceId: id,
      page: 1,
      per: 500 
    })
  }
)
</script>