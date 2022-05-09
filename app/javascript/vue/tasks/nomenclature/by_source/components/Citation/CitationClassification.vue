<template>
  <div>
    <VSpinner v-if="isLoading" />
    <div class="flex-separate middle">
      <h2>Nomenclatural statuses</h2>
      <button
        class="button normal-input button-default"
        :disabled="!citations.length"
        @click="loadOtuByProxy('taxon_name_classification_ids')"
      >
        Summarize OTUs
      </button>
    </div>
    <VTable :list="citations" />
  </div>
</template>

<script setup>
import VTable from '../tables/classification_table.vue'
import VSpinner from 'components/spinner.vue'
import useCitation from '../../composables/useCitation.js'
import { TAXON_NAME_CLASSIFICATION } from 'constants/index.js'

const { 
  isLoading,
  citations,
  requestCitations,
  loadOtuByProxy,
  pagination
} = useCitation(TAXON_NAME_CLASSIFICATION)

</script>