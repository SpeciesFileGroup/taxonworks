<template>
  <div>
    <h3>Return</h3>
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
      :disabled="!date || !status || !loan"
      @click="updateLoanItems"
    >
      Update
    </VBtn>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { LoanItem } from 'routes/endpoints'
import { LOAN_STATUS_LIST } from 'constants/index.js'
import VDateNow from 'components/ui/Date/DateNow.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import SmartSelector from 'components/ui/SmartSelector'
import SmartSelectorItem from 'components/ui/SmartSelectorItem'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const date = ref(null)
const status = ref(null)
const loan = ref(null)

function updateLoanItems() {
  const payload = {
    batch_type: 'collection_object_filter',
    collection_object_query: props.parameters,
    disposition: status.value,
    date_returned: date.value,
    loan_id: loan.value.id
  }

  LoanItem.moveBatch(payload).then(({ body }) => {
    TW.workbench.alert.create(
      `${body.length} Loan items were successfully updated.`,
      'notice'
    )
  })
}
</script>
