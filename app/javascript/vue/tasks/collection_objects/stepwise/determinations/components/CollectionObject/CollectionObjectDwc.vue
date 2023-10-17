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
            v-for="(value, index) in dwc?.column_headers"
            :key="value"
          >
            <td>{{ value }}</td>
            <td>{{ dwc.data[0][index] }}</td>
          </tr>
        </tbody>
      </table>
      <VSpinner v-if="isLoading" />
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/spinner.vue'

const props = defineProps({
  collectionObjectId: {
    type: Number,
    required: true
  }
})

const isLoading = ref(true)
const dwc = ref({})

CollectionObject.dwcIndex({
  collection_object_id: [props.collectionObjectId]
})
  .then(({ body }) => {
    dwc.value = body
  })
  .finally(() => {
    isLoading.value = false
  })
</script>
