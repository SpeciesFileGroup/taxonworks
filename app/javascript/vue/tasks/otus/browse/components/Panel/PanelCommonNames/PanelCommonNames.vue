<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <TableDisplay
      v-if="commonNames.length"
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
    <div v-else>No common names available</div>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { CommonName } from '@/routes/endpoints'
import PanelLayout from '../PanelLayout.vue'
import TableDisplay from '@/components/table_list'

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

const commonNames = ref([])
const isLoading = ref(false)

async function loadCommonNames(otus) {
  isLoading.value = true

  try {
    const otuIds = otus.map((o) => o.id)
    const { body } = await CommonName.all({ otu_id: otuIds })

    commonNames.value = body
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length > 0) {
      loadCommonNames(newVal)
    }
  },
  { immediate: true }
)
</script>
