<template>
  <div>
    <VSpinner v-if="isLoading" />
    <div class="flex-separate middle">
      <h2>OTUs</h2>
      <button
        @click="loadOtuByProxy('otu_ids')"
        :disabled="!citations.length"
        class="button normal-input button-default"
      >
        Summarize OTUs
      </button>
    </div>
    <VTable :list="citations" />
  </div>
</template>

<script setup>
import VTable from '../tables/table.vue'
import VSpinner from 'components/spinner.vue'
import useCitation from '../../composables/useCitation.js'
import { ASSERTED_DISTRIBUTION } from 'constants/index.js'

const { 
  isLoading,
  citations,
  requestCitations,
  loadOtuByProxy,
  pagination
} = useCitation(ASSERTED_DISTRIBUTION)

</script>