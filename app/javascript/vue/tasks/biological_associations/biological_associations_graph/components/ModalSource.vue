<template>
  <VModal :container-style="{ width: '800px', maxHeight: '50vh' }">
    <template #header>
      <h3>Sources</h3>
    </template>
    <template #body>
      <table class="table-striped">
        <thead>
          <tr>
            <th class="full_width">Source</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="source in sources"
            :key="source.id"
          >
            <td v-html="source.object_tag" />
          </tr>
        </tbody>
      </table>
      <VSpinner v-if="isLoading" />
    </template>
  </VModal>
</template>

<script setup>
import VSpinner from '@/components/spinner.vue'
import VModal from '@/components/ui/Modal'
import { Source } from '@/routes/endpoints'
import { ref, onBeforeMount } from 'vue'

const props = defineProps({
  sourceId: {
    type: Array,
    default: () => []
  }
})

const sources = ref([])
const isLoading = ref(false)

onBeforeMount(() => {
  if (props.sourceId.length) {
    isLoading.value = true
    Source.where({ source_id: props.sourceId })
      .then(({ body }) => {
        sources.value = body
      })
      .finally(() => {
        isLoading.value = false
      })
  }
})
</script>
