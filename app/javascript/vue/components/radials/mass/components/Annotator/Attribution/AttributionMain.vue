<template>
  <AttributionComponent
    :type="type"
    @attribution="(attribution) => makeBatchRequest(attribution)"
  />
  <VSpinner
    v-if="isSaving"
    legend="Creating attributions..."
  />
  <ConfirmationModal
    ref="confirmationModalRef"
    :container-style="{ 'min-width': 'auto', width: '300px' }"
  />

  <VModal
    v-if="isTableVisible"
    @close="() => (isTableVisible = false)"
  >
    <template #header>
      <h3>Response</h3>
    </template>
    <template #body>
      <PreviewTable :data="response" />
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import { Attribution } from '@/routes/endpoints'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import AttributionComponent from './attributions.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import PreviewTable from '@/components/radials/shared/PreviewTable.vue'
import VModal from '@/components/ui/Modal.vue'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  },

  parameters: {
    type: Object,
    default: undefined
  },

  nestedQuery: {
    type: Boolean,
    default: false
  }
})

const isSaving = ref(false)
const isTableVisible = ref(false)
const confirmationModalRef = ref(null)
const response = ref(null)

const queryParam = computed(() => [QUERY_PARAM[props.objectType]])

async function makeBatchRequest(attribution) {
  const ok = await confirmationModalRef.value.show({
    title: 'Attributions',
    message: 'Are you sure you want to proceed?',
    confirmationWord: 'CREATE',
    okButton: 'Create',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    const idParam = ID_PARAM_FOR[props.objectType]
    const payload = {
      ...attribution,
      mode: 'add',
      filter_query: filterQuery()
    }

    if (props.ids?.length) {
      payload.filter_query[queryParam.value][idParam] = props.ids
    }

    isSaving.value = true
    Attribution.batchByFilter(payload)
      .then(({ body }) => {
        response.value = body
        isTableVisible.value = true
      })
      .finally(() => {
        isSaving.value = false
      })
  }
}

function filterQuery() {
  return props.nestedQuery
    ? props.parameters
    : {[QUERY_PARAM[props.objectType]]: props.parameters}
}
</script>
