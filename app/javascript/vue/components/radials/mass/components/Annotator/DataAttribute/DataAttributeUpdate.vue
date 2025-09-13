<template>
  <div class="data_attribute_annotator">
    <VSpinner
      v-if="isUpdating"
      full-screen
    />
    <SmartSelector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Predicate' }"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      klass="DataAttribute"
      :custom-list="{ all: controlledVocabularyTerms }"
      @selected="
        (item) => {
          predicate = item
        }
      "
    />
    <SmartSelectorItem
      :item="predicate"
      label="name"
      @unset="
        () => {
          predicate = undefined
        }
      "
    />
    <textarea
      v-model="fromValue"
      class="separate-bottom"
      placeholder="From value"
    />
    <textarea
      v-model="toValue"
      class="separate-bottom"
      placeholder="To value"
    />
    <div class="horizontal-left-content gap-small">
      <button
        type="button"
        :disabled="!validateFields"
        class="button button-submit normal-input separate-bottom"
        @click="updateDataAttributes"
      >
        Update or Create
      </button>
      <button
        @click="
          () => {
            resetForm()
          }
        "
        :disabled="!validateFields"
        class="button button-default normal-input separate-bottom"
        type="button"
      >
        Reset
      </button>
    </div>
    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ControlledVocabularyTerm, DataAttribute } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import confirmationOpts from '../../../constants/confirmationOpts.js'

const props = defineProps({
  parameters: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  },

  controlledVocabularyTerms: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['create'])

const confirmationModalRef = ref(null)
const isUpdating = ref(false)
const predicate = ref()
const fromValue = ref('')
const toValue = ref('')

const validateFields = computed(() => predicate.value && toValue.value.length)

function resetForm() {
  toValue.value = ''
  fromValue.value = ''
  predicate.value = undefined
}

async function updateDataAttributes() {
  const ok = await confirmationModalRef.value.show(confirmationOpts)

  if (ok) {
    const payload = {
      ...props.parameters,
      predicate_id: predicate.value.id,
      value_from: fromValue.value,
      value_to: toValue.value
    }

    isUpdating.value = true
    DataAttribute.updateBatch(payload)
      .then(({ body }) => {
        TW.workbench.alert.create(
          'Data attribute(s) were successfully updated',
          'notice'
        )
        resetForm()
        emit('create', body)
      })
      .catch(() => {})
      .finally(() => {
        isUpdating.value = false
      })
  }
}

const all = ref([])

ControlledVocabularyTerm.where({ type: ['Predicate'] }).then(({ body }) => {
  all.value = body
})
</script>
<style lang="scss">
.radial-annotator {
  .data_attribute_annotator {
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      height: 100px;
    }

    .vue-autocomplete-input {
      width: 100%;
    }
  }
}
</style>
