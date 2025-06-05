<template>
  <div>
    <VSpinner
      v-if="isProcessing"
      legend="Updating..."
    />
    <h3>Mode</h3>
    <ul class="no_bullets">
      <li
        v-for="mode in MODES"
        :key="mode['mode']"
      >
        <label>
          <input
            type="radio"
            :value="mode"
            v-model="selectedMode"
          />
          {{ mode['display'] }}
        </label>
      </li>
    </ul>

    <PredicateValueSelector
      v-if="selectedMode.mode == 'add' || selectedMode.mode == 'remove'"
      v-model:predicate="predicate"
      v-model:predicate-value1="predicateValue"
      :text-box1-default="selectedMode.textBox1Text"
      :controlled-vocabulary-terms="cvtList"
      class="separate-top"
    />

    <PredicateValueSelector
      v-else
      v-model:predicate="predicate"
      v-model:predicate-value1="predicateValueFrom"
      v-model:predicate-value2="predicateValueTo"
      :text-box1-default="selectedMode.textBox1Text"
      :text-box2-default="selectedMode.textBox2Text"
      :controlled-vocabulary-terms="cvtList"
      class="separate-top"
    />

    <div class="horizontal-left-content gap-small">
      <button
        @click="makeBatchRequest"
        :disabled="submitDisabled"
        class="button button-submit normal-input separate-bottom"
        type="button"
      >
        {{ selectedMode.display }}
      </button>
      <button
        @click="
          () => {
            resetForm()
          }
        "
        :disabled="submitDisabled"
        class="button button-default normal-input separate-bottom"
        type="button"
      >
        New
      </button>
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
import { computed, ref, onBeforeMount, shallowRef } from 'vue'
import { ControlledVocabularyTerm, DataAttribute } from '@/routes/endpoints'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam.js'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import PreviewTable from '@/components/radials/shared/PreviewTable.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import PredicateValueSelector from './PredicateValueSelector.vue'

const MODES = [
  { mode: 'add', display: 'Add', textBox1Text: 'Value', textBox2Text: '',
    confirmationWord: 'CREATE'
   },
  { mode: 'remove', display: 'Remove',  textBox1Text: 'Value', textBox2Text: '',
    confirmationWord: 'DELETE'
  },
  { mode: 'replace', display: 'Replace', textBox1Text: 'From',
    textBox2Text: 'To', confirmationWord: 'UPDATE' }
]

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

const confirmationModalRef = ref(null)
const cvtList = ref([])
const response = ref(null)
const isTableVisible = ref(false)
const isProcessing = ref(false)
const predicate = ref(null)
const predicateValue = ref(null) // Value for create or delete
const predicateValueFrom = ref(null) // For update
const predicateValueTo = ref(null) // For update

const selectedMode = shallowRef(MODES[0]) // Add

const submitDisabled = computed(
  () => {
    if (selectedMode.value.mode == 'add' || selectedMode.value.mode == 'remove') {
      return !(predicate.value && predicateValue.value?.length)
    } else {
      return !(predicate.value && predicateValueFrom.value?.length &&
        predicateValueTo.value?.length)
    }
  }
)

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: ['Predicate'] }).then(({ body }) => {
    cvtList.value = body
  })
})

async function makeBatchRequest() {
  const ok = await confirmationModalRef.value.show({
    title: 'Data attributes',
    message: 'Are you sure you want to proceed?',
    confirmationWord: selectedMode.value.confirmationWord,
    okButton: 'Create',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    const idParam = ID_PARAM_FOR[props.objectType]
    const payload = selectedMode.value.mode == 'replace'
      ? makeUpdatePayload()
      : makeCreateOrDeletePayload()

    if (props.ids?.length) {
      payload.filter_query[idParam] = props.ids
    }

    isProcessing.value = true
    DataAttribute.batchByFilterScope(payload)
      .then(({ body }) => {
        response.value = body
        isTableVisible.value = true
      })
      .catch(() => {})
      .finally(() => {
        isProcessing.value = false
      })
  }
}

function makeCreateOrDeletePayload() {
  return {
    filter_query: filterQuery(),
    mode: selectedMode.value.mode,
    params: {
      type: 'InternalAttribute',
      predicate_id: predicate.value.id,
      value: predicateValue.value
    }
  }
}

function makeUpdatePayload() {
  return {
    filter_query: filterQuery(),
    mode: selectedMode.value.mode,
    params: {
      type: 'InternalAttribute',
      predicate_id: predicate.value.id,
      value_from: predicateValueFrom.value,
      value_to: predicateValueTo.value
    }
  }
}

function filterQuery() {
  return props.nestedQuery
    ? props.parameters
    : {[QUERY_PARAM[props.objectType]]: props.parameters}
}

function resetForm() {
  predicate.value = null
  predicateValue.value = ''
  predicateValueFrom.value = ''
  predicateValueTo.value = ''

}
</script>
