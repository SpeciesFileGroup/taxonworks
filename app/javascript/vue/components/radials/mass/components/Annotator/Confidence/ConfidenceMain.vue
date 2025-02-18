<template>
  <div class="confidence_annotator">
    <VSpinner
      v-if="isProcessing"
      legend="Updating..."
    />
    <h3>Mode</h3>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in MODE"
        :key="key"
      >
        <label>
          <input
            type="radio"
            :value="value"
            v-model="selectedMode"
          />
          {{ key }}
        </label>
      </li>
    </ul>

    <component
      :is="selectedMode.component"
      :color="selectedMode.color"
      :list="list"
      @select="makeBatchRequest"
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
  </div>
</template>

<script setup>
import { computed, ref, onBeforeMount, shallowRef } from 'vue'
import { ControlledVocabularyTerm, Confidence } from '@/routes/endpoints'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam.js'
import { CONFIDENCE_LEVEL } from '@/constants'
import ConfidenceList from './ConfidenceList.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import PreviewTable from '@/components/radials/shared/PreviewTable.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ConfidenceReplace from './ConfidenceReplace.vue'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  parameters: {
    type: Object,
    default: undefined
  }
})

const MODE = {
  Add: { mode: 'add', component: ConfidenceList, color: 'create' },
  Remove: { mode: 'remove', component: ConfidenceList, color: 'destroy' },
  Replace: { mode: 'replace', component: ConfidenceReplace, color: 'primary' }
}

const queryParam = computed(() => [QUERY_PARAM[props.objectType]])
const confirmationModalRef = ref(null)
const list = ref([])
const response = ref(null)
const isTableVisible = ref(false)
const isProcessing = ref(false)

const selectedMode = shallowRef(MODE.Add)

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: [CONFIDENCE_LEVEL] }).then(
    ({ body }) => {
      list.value = body
    }
  )
})

async function makeBatchRequest(confidence) {
  const ok = await confirmationModalRef.value.show({
    title: 'Confidences',
    message: 'Are you sure you want to proceed?',
    confirmationWord: 'UPDATE',
    okButton: 'Create',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    const idParam = ID_PARAM_FOR[props.objectType]
    const payload = Array.isArray(confidence)
      ? makeReplacePayload(confidence)
      : makePayload(confidence)

    if (props.ids?.length) {
      payload.filter_query[queryParam.value][idParam] = props.ids
    }

    isProcessing.value = true
    Confidence.batchByFilter(payload)
      .then(({ body }) => {
        response.value = body
        isTableVisible.value = true
      })
      .finally(() => {
        isProcessing.value = false
      })
  }
}

function makePayload(confidence) {
  return {
    mode: selectedMode.value.mode,
    confidence_level_id: confidence.id,
    filter_query: {
      [queryParam.value]: props.parameters
    }
  }
}

function makeReplacePayload([replace, to]) {
  return {
    mode: selectedMode.value.mode,
    confidence_level_id: to.id,
    replace_confidence_level_id: replace.id,
    filter_query: props.parameters
  }
}
</script>
