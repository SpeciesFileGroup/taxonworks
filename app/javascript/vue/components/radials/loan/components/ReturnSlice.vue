<template>
  <div>
    <div class="field label-above">
      <label>Status</label>
      <select
        v-model="status"
        class="normal-input information-input"
      >
        <option
          v-for="item in LOAN_STATUS_LIST"
          :key="item"
          :value="item"
        >
          {{ item }}
        </option>
      </select>
    </div>
    <div class="field label-above">
      <label>Date</label>
      <div class="horizontal-left-content">
        <input
          type="date"
          v-model="date"
        />
        <VDateNow
          class="margin-small-left"
          v-model:date="date"
        />
      </div>
    </div>

    <VBtn
      color="create"
      medium
      :disabled="!date || !status || isLoading"
      @click="updateLoanItems"
    >
      Update
    </VBtn>

    <VSpinner
      v-if="isLoading"
      legend="Returning items..."
    />

    <div
      v-if="response"
      class="margin-large-top"
    >
      <PreviewTable :data="response" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { LoanItem } from '@/routes/endpoints'
import { LOAN_STATUS_LIST } from '@/constants/index.js'
import VDateNow from '@/components/ui/Date/DateNow.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import PreviewTable from '@/components/radials/shared/PreviewTable.vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const date = ref(null)
const status = ref(null)
const response = ref(null)
const isLoading = ref(false)

function updateLoanItems() {
  const payload = {
    filter_query: {
      collection_object_query: props.parameters
    },
    mode: 'return',
    params: {
      disposition: status.value,
      date_returned: date.value
    }
  }

  isLoading.value = true
  response.value = null

  LoanItem.batchByFilter(payload)
    .then(({ body }) => {
      response.value = body

      const updatedCount = body.updated?.length || 0
      const notUpdatedCount = body.not_updated?.length || 0

      if (updatedCount > 0 && notUpdatedCount === 0) {
        TW.workbench.alert.create(
          `${updatedCount} loan item(s) successfully returned.`,
          'notice'
        )
      } else if (updatedCount > 0 && notUpdatedCount > 0) {
        TW.workbench.alert.create(
          `${updatedCount} loan item(s) returned, ${notUpdatedCount} not on loan.`,
          'notice'
        )
      } else if (notUpdatedCount > 0) {
        TW.workbench.alert.create(
          `No loan items returned. ${notUpdatedCount} not currently on loan.`,
          'error'
        )
      } else {
        TW.workbench.alert.create(
          'No collection objects matched the filter.',
          'notice'
        )
      }
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}
</script>
