<template>
  <div>
    <fieldset>
      <legend>Loan</legend>
      <SmartSelector
        model="loans"
        @selected="addToLoan"
      />
    </fieldset>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import { LoanItem } from 'routes/endpoints'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

function addToLoan(loan) {
  const payload = {
    batch_type: 'collection_object_filter',
    collection_object_query: props.parameters,
    loan_id: loan.id
  }

  LoanItem.createBatch(payload).then(() => {
    TW.workbench.alert.create('Loan items were successfully updated.', 'notice')
  })
}
</script>
