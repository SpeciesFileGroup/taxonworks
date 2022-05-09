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

    <div
      v-if="pagination"
      class="flex-separate margin-medium-bottom"
    >
      <VPagination 
        :pagination="pagination"
        @next-page="requestCitations"
      />
      <VPaginationCount
        :pagination="pagination"
        v-model="per"
      />
    </div>
    <TableCitation
      class="full_width"
      :list="citations"
    />
  </div>
</template>

<script setup>
import VSpinner from 'components/spinner.vue'
import TableCitation from './Table/TableCitation.vue'
import useCitation from '../composables/useCitation.js'
import VPagination from 'components/pagination.vue'
import VPaginationCount from 'components/pagination/PaginationCount.vue'

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
  pagination,
  per
} = useCitation(props.type)

</script>
