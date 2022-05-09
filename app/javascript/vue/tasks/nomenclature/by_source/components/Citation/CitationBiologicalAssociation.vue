<template>
  <div>
    <VSpinner v-if="isLoading" />
    <div class="flex-separate middle">
      <h2>Biological associations</h2>
      <button
        @click="loadOtuByProxy('biological_association_ids')"
        :disabled="!citations.length"
        class="button normal-input button-default"
      >
        Summarize OTUs
      </button>
    </div>
    <TaxonNameTable :list="citations" />
  </div>
</template>

<script setup>
import TaxonNameTable from '../tables/taxon_names_table.vue'
import VSpinner from 'components/spinner.vue'
import useCitation from '../../composables/useCitation.js'
import { BIOLOGICAL_ASSOCIATION } from 'constants/index.js'

const { 
  isLoading,
  citations,
  requestCitations,
  loadOtuByProxy,
  pagination
} = useCitation(BIOLOGICAL_ASSOCIATION)

</script>