<template>
  <div>
    <VSpinner v-if="isLoading"/>
    <div class="flex-separate middle">
      <h2>Asserted distributions</h2>
      <button
        @click="loadOtuByProxy('asserted_distribution_ids')"
        :disabled="!citations.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <VTable :list="citations"/>
  </div>
</template>
<script setup>

import VTable from '../tables/table.vue'
import VSpinner from 'components/spinner.vue'
import useCitation from '../../composable/useCitation.js'
import { watch } from 'vue'
import { ASSERTED_DISTRIBUTION } from 'constants/index.js'

const props = defineProps({
  sourceId: {
    type: String,
    default: undefined
  }
})

const { 
  isLoading,
  citations,
  requestCitations,
  loadOtuByProxy,
  pagination
} = useCitation(ASSERTED_DISTRIBUTION)

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