<template>
  <div>
    <VSpinner v-if="isLoading" />
    <div class="flex-separate middle">
      <h2>{{ title }}</h2>
      <VBtn
        color="primary"
        :disabled="!citations.length"
        medium
        tonal
        @click="loadOtuByProxy(summarizeParam)"
      >
        Summarize OTUs
      </VBtn>
    </div>

    <div
      v-if="pagination"
      class="flex-separate margin-medium-bottom"
    >
      <VPagination
        :pagination="pagination"
        @next-page="({ page }) => requestCitations({ page, per })"
      />
      <VPaginationCount
        :pagination="pagination"
        v-model="per"
      />
    </div>
    <TableCitation
      class="full_width"
      :type="type"
      :list="citations"
    />
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'
import TableCitation from './Table/TableCitation.vue'
import useCitation from '../composables/useCitation.js'
import VPagination from '@/components/pagination.vue'
import VPaginationCount from '@/components/pagination/PaginationCount.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

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
