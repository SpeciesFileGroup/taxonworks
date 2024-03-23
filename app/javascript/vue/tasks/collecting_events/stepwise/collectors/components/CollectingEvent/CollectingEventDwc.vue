<template>
  <VModal :container-style="{ width: '800px' }">
    <template #header>
      <h3>DwC Attributes</h3>
    </template>
    <template #body>
      <table class="full_width table-striped">
        <thead>
          <tr>
            <th>Attribute</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="attribute in headers"
            :key="attribute.name"
          >
            <td>{{ attribute.name }}</td>
            <td>{{ dwc[attribute.name] }}</td>
          </tr>
        </tbody>
      </table>
      <VSpinner v-if="isLoading" />
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { CollectingEvent } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  collectingEventId: {
    type: Number,
    required: true
  }
})

const isLoading = ref(true)
const dwc = ref({})

const headers = ref([])

CollectingEvent.attributes().then(({ body }) => {
  headers.value = body
})

CollectingEvent.find(props.collectingEventId)
  .then(({ body }) => {
    dwc.value = body
  })
  .finally(() => {
    isLoading.value = false
  })
</script>
