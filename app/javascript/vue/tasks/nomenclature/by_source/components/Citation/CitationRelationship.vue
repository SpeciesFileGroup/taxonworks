<template>
  <div>
    <VSpinner v-if="isLoading" />
    <div class="flex-separate middle">
      <h2>Taxon name relationships</h2>
      <button
        class="button normal-input button-default"
        :disabled="!citations.length"
        @click="loadOtuByProxy('taxon_name_relationship_ids')"
      >
        Summarize OTUs
      </button>
    </div>
    <VTable :list="citations" />
  </div>
</template>

<script setup>
import VTable from '../tables/taxon_names_table.vue'
import VSpinner from 'components/spinner.vue'
import useCitation from '../../composables/useCitation.js'
import { TAXON_NAME_RELATIONSHIP } from 'constants/index.js'

const { 
  isLoading,
  citations,
  requestCitations,
  loadOtuByProxy,
  pagination
} = useCitation(TAXON_NAME_RELATIONSHIP)

</script>
