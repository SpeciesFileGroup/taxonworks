<template>
  <div>
    <VSpinner v-if="isLoading" />
    <div class="flex-separate middle">
      <h2>{{ title }}</h2>
      <button
        @click="loadOtuByProxy(summarizeParam)"
        :disabled="!citations.length"
        class="button normal-input button-default"
      >
        Summarize OTUs
      </button>
    </div>
    <TableCitation
      class="full_width"
      :list="citations"
    />
  </div>
</template>

<script setup>
import VSpinner from 'components/spinner.vue'
import TableCitation from './tables/TableCitation.vue'
import useCitation from '../composables/useCitation.js'

const props = defineProps({
  title: {
    type: String,
    required: true
  },

  type: {
    type: String,
    required: true
  },

  summarizeParam: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['summarize'])

const { 
  isLoading,
  citations,
  requestCitations,
  loadOtuByProxy,
  pagination
} = useCitation(props.type)

</script>
