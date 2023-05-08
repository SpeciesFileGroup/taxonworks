<template>
  <div>
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

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!loan"
      @click="addToLoan"
    >
      Add
    </VBtn>

    <div
      v-if="created.length"
      class="margin-large-top"
    >
      <h3>Created</h3>
      <ul>
        <li
          v-for="item in created"
          :key="item.id"
          v-html="item.object_tag"
        />
      </ul>
      <a :href="`/tasks/loans/edit_loan/${loan.id}`">Edit loan items</a>
    </div>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { LoanItem } from 'routes/endpoints'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const loan = ref()
const created = ref([])

function addToLoan() {
  const payload = {
    batch_type: 'collection_object_filter',
    collection_object_query: props.parameters,
    loan_id: loan.value.id
  }

  LoanItem.createBatch(payload).then(({ body }) => {
    created.value = body
    TW.workbench.alert.create(
      `${body.length} Loan items were successfully created.`,
      'notice'
    )
  })
}
</script>
