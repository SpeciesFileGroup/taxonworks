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

    <div class="margin-large-top">
      <h3>Add</h3>
      <fieldset>
        <legend>Loan</legend>
        <SmartSelector
          model="loans"
          @selected="(item) => (loan = item)"
        />
        <SmartSelectorItem
          :item="loan"
          @unset="loan = undefined"
        />
      </fieldset>
    </div>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!date || !status || !loan || isLoading"
      @click="updateLoanItems"
    >
      Update
    </VBtn>

    <VSpinner
      v-if="isLoading"
      legend="Moving items..."
    />

    <div
      v-if="response"
      class="margin-large-top"
    >
      <PreviewTable :data="response" />
      <a
        v-if="response.updated?.length"
        class="margin-medium-top"
        :href="`${RouteNames.EditLoan}/${loan.id}`"
      >
        Edit loan items
      </a>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { LoanItem } from '@/routes/endpoints'
import { LOAN_STATUS_LIST } from '@/constants/index.js'
import { RouteNames } from '@/routes/routes'
import VDateNow from '@/components/ui/Date/DateNow.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import PreviewTable from '@/components/radials/shared/PreviewTable.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const date = ref(null)
const status = ref(null)
const loan = ref(null)
const response = ref(null)
const isLoading = ref(false)

function updateLoanItems() {
  const payload = {
    filter_query: {
      collection_object_query: props.parameters
    },
    mode: 'move',
    params: {
      disposition: status.value,
      date_returned: date.value,
      loan_id: loan.value.id
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
          `${updatedCount} loan item(s) successfully moved.`,
          'notice'
        )
      } else if (updatedCount > 0 && notUpdatedCount > 0) {
        TW.workbench.alert.create(
          `${updatedCount} loan item(s) moved, ${notUpdatedCount} not on loan.`,
          'notice'
        )
      } else if (notUpdatedCount > 0) {
        TW.workbench.alert.create(
          `No loan items moved. ${notUpdatedCount} not currently on loan.`,
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
