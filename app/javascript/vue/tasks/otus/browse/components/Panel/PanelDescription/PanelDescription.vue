<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <div v-if="generatedDescription">
      {{ generatedDescription }}
    </div>
    <div v-else>No description available</div>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import ajaxCall from '@/helpers/ajaxCall'
import PanelLayout from '../PanelLayout.vue'

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
    default: 'Description'
  }
})

const generatedDescription = ref('')
const isLoading = ref(false)

async function loadDescription(otuId) {
  const urlParams = new URLSearchParams(window.location.search)
  const matrixId = urlParams.get('observation_matrix_id')

  isLoading.value = true

  try {
    const { body } = await ajaxCall(
      'get',
      '/tasks/observation_matrices/description_from_observation_matrix/description',
      {
        params: {
          otu_id: otuId,
          include_descendants: true,
          observation_matrix_id: /^\d+$/.test(matrixId) ? matrixId : undefined
        }
      }
    )

    generatedDescription.value = body.generated_description
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otu,
  (newVal) => {
    if (newVal?.id) {
      loadDescription(newVal.id)
    }
  },
  { immediate: true }
)
</script>
