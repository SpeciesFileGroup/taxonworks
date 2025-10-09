<template>
  <div>
    <VSpinner
      v-if="isProcessing"
      legend="Updating..."
    />

    <div class="identifier-annotator">
      <IdentifierType
        :types="IDENTIFIER_TYPES[objectType]"
        v-model="identifierTypes"
      />

      <NamespaceSelect
        :identifier-types="identifierTypes"
        :filter-query="filterQuery()"
        :object-type="objectType"
        v-model:namespace="namespace"
        v-model:virtual-namespace-prefix="virtualNamespacePrefix"
        v-model:namespaces-to-replace="namespacesToReplace"
        class="namespace-select"
      />

      <VBtn
        :disabled="!updateEnabled"
        type="button"
        color="create"
        medium
        @click="() => makeBatchRequest()"
      >
        Update
      </VBtn>
    </div>

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
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { COLLECTING_EVENT, COLLECTION_OBJECT } from '@/constants'
import { Identifier } from '@/routes/endpoints'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import {
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_FIELD_NUMBER
} from '@/constants'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import NamespaceSelect from './NamespaceSelect.vue'
import PreviewTable from '@/components/radials/shared/PreviewTable.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import IdentifierType from './IdentifierType.vue'

const IDENTIFIER_TYPES = {
  [COLLECTION_OBJECT]: [
    {
      display: 'Catalog Numbers',
      klass: IDENTIFIER_LOCAL_CATALOG_NUMBER
    },
    {
      display: 'Record Numbers',
      klass: IDENTIFIER_LOCAL_RECORD_NUMBER
    }
  ],
  [COLLECTING_EVENT]: [
    {
      display: 'Field Numbers',
      klass: IDENTIFIER_LOCAL_FIELD_NUMBER
    }
  ]
}

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

const queryParam = computed(() => [QUERY_PARAM[props.objectType]])
const confirmationModalRef = ref(null)
const response = ref(null)
const isTableVisible = ref(false)
const isProcessing = ref(false)
const identifierTypes = ref(
  props.objectType == COLLECTING_EVENT
    ? [IDENTIFIER_TYPES[COLLECTING_EVENT][0]['klass']]
    : []
  )
const namespace = ref(null)
const virtualNamespacePrefix = ref(null)
const namespacesToReplace = ref([])

const updateEnabled = computed(() => {
  return identifierTypes.value.length && !!(namespace.value) &&
    namespacesToReplace.value.length > 0
})

async function makeBatchRequest() {
  const ok = await confirmationModalRef.value.show({
    title: 'Identifiers',
    message: 'Are you sure you want to proceed?',
    confirmationWord: 'UPDATE',
    okButton: 'Update',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (!ok) return

  const idParam = ID_PARAM_FOR[props.objectType]
  const payload = {
    filter_query: filterQuery(),
    mode: 'replace',
    params: {
      identifier_types: identifierTypes.value,
      namespace_id: namespace.value.id,
      virtual_namespace_prefix: virtualNamespacePrefix.value,
      namespaces_to_replace: namespacesToReplace.value
    }
  }

  if (props.ids?.length) {
    payload.filter_query[queryParam.value][idParam] = props.ids
  }

  isProcessing.value = true
  Identifier.batchByFilter(payload)
    .then(({ body }) => {
      response.value = body
      isTableVisible.value = true
    })
    .catch(() => {})
    .finally(() => {
      isProcessing.value = false
    })
}

function filterQuery() {
  return props.nestedQuery
    ? props.parameters
    : {[QUERY_PARAM[props.objectType]]: props.parameters}
}
</script>

<style scoped>
.identifier-annotator {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 2em;
}

.namespace-select {
  width: 100%;
}
</style>
