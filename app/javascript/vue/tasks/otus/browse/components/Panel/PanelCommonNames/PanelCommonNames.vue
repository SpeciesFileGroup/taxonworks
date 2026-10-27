<template>
  <PanelLayout
    :status="status"
    :spinner="isLoading"
    :empty="!commonNames.length"
    :name="title"
    :title="`${title} ${pagination ? '(' + pagination.total + ')' : ''}`"
  >
    <template v-if="commonNames.length">
      <VPagination
        v-if="pagination"
        class="margin-small-top margin-small-bottom"
        :pagination="pagination"
        @next-page="(e) => loadCommonNames(e.page)"
      />
      <TableDisplay
        :list="commonNames"
        :header="[
          'Name',
          'Geographic area',
          'Language',
          'Start year',
          'End year',
          ''
        ]"
        :destroy="false"
        :attributes="[
          'object_tag',
          ['geographic_area', 'object_tag'],
          'language_tag',
          'start_year',
          'end_year'
        ]"
      />
    </template>
    <div v-else>No common names available</div>
  </PanelLayout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { CommonName } from '@/routes/endpoints'
import { getPagination } from '@/helpers'
import PanelLayout from '../PanelLayout.vue'
import TableDisplay from '@/components/table_list'
import VPagination from '@/components/pagination.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Common names'
  }
})

const PER_PAGE = 50

const commonNames = ref([])
const isLoading = ref(false)
const pagination = ref()

const otuIds = computed(() => props.otus.map((o) => o.id))

async function loadCommonNames(page = 1) {
  isLoading.value = true

  try {
    const response = await CommonName.filter({
      otu_id: otuIds.value,
      page,
      per: PER_PAGE
    })

    pagination.value = getPagination(response)
    commonNames.value = response.body
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length > 0) {
      loadCommonNames()
    }
  },
  { immediate: true }
)
</script>
