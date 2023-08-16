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
      :disabled="!date || !status"
      @click="updateLoanItems"
    >
      Update
    </VBtn>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { LoanItem } from '@/routes/endpoints'
import { LOAN_STATUS_LIST } from '@/constants/index.js'
import VDateNow from '@/components/ui/Date/DateNow.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const date = ref(null)
const status = ref(null)

function updateLoanItems() {
  const payload = {
    batch_type: 'collection_object_filter',
    collection_object_query: props.parameters,
    disposition: status.value,
    date_returned: date.value
  }

  LoanItem.returnBatch(payload).then(({ body }) => {
    TW.workbench.alert.create(
      `${body.length} Loan items were successfully returned.`,
      'notice'
    )
  })
}
</script>
