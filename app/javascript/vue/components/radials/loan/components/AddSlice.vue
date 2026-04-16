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
      :disabled="!loan || isLoading"
      @click="addToLoan"
    >
      Add
    </VBtn>

    <VSpinner
      v-if="isLoading"
      legend="Adding to loan..."
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
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import PreviewTable from '@/components/radials/shared/PreviewTable.vue'
import { LoanItem } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const loan = ref()
const response = ref(null)
const isLoading = ref(false)

function addToLoan() {
  const payload = {
    filter_query: {
      collection_object_query: props.parameters
    },
    mode: 'add',
    params: {
      loan_id: loan.value.id
    }
  }

  isLoading.value = true
  response.value = null

  LoanItem.batchByFilter(payload)
    .then(handleResponse)
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}

function handleResponse({ body }) {
  response.value = body

  const updatedCount = body.updated?.length || 0
  const notUpdatedCount = body.not_updated?.length || 0

  if (updatedCount > 0 && notUpdatedCount === 0) {
    TW.workbench.alert.create(
      `${updatedCount} loan item(s) successfully created.`,
      'notice'
    )
  } else if (updatedCount > 0 && notUpdatedCount > 0) {
    TW.workbench.alert.create(
      `${updatedCount} loan item(s) created, ${notUpdatedCount} already on loan.`,
      'notice'
    )
  } else if (notUpdatedCount > 0) {
    TW.workbench.alert.create(
      `No loan items created. ${notUpdatedCount} already on loan.`,
      'error'
    )
  } else {
    TW.workbench.alert.create(
      'No collection objects matched the filter.',
      'notice'
    )
  }
}
</script>
