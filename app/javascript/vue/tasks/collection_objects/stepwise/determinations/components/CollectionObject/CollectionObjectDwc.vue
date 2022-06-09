<template>
  <VModal
    :container-style="{ width: '800px' }"
  >
    <template #header>
      <h3>DwC Attributes</h3>
    </template>
    <template #body>
      <table class="full_width">
        <thead>
          <tr>
            <th>Attribute</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(value, attr, index) in dwcAttributes"
            :key="attr"
            class="list-complete-item contextMenuCells"
            :class="{ even: index % 2}"
          >
            <td>{{ attr }}</td>
            <td>{{ value }}</td>
          </tr>
        </tbody>
      </table>
      <VSpinner v-if="isLoading" />
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import VModal from 'components/ui/Modal.vue'
import VSpinner from 'components/spinner.vue'

const props = defineProps({
  collectionObjectId: {
    type: Number,
    required: true
  }
})

const isLoading = ref(true)
const dwcAttributes = ref({})

CollectionObject.find(props.collectionObjectId, { extend: ['dwc_fields'] }).then(({ body }) => {
  isLoading.value = false
  dwcAttributes.value = body.dwc
})

</script>
