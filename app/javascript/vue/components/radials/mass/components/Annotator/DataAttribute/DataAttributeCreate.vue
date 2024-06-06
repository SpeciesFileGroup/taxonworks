<template>
  <div class="data_attribute_annotator">
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
      v-model="inputValue"
      class="separate-bottom"
      placeholder="Value"
    />
    <div class="horizontal-left-content gap-small">
      <button
        @click="createDataAttributes()"
        :disabled="!validateFields"
        class="button button-submit normal-input separate-bottom"
        type="button"
      >
        Create
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
        New
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
import { DataAttribute } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import confirmationOpts from '../../../constants/confirmationOpts.js'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  parameters: {
    type: Object,
    default: () => ({})
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
const predicate = ref()
const inputValue = ref('')

const validateFields = computed(
  () => predicate.value && inputValue.value.length
)

function resetForm() {
  inputValue.value = ''
  predicate.value = undefined
}

async function createDataAttributes() {
  const ok = await confirmationModalRef.value.show(confirmationOpts)

  if (ok) {
    DataAttribute.createBatch({
      attribute_subject_id: props.ids,
      attribute_subject_type: props.objectType,
      type: 'InternalAttribute',
      controlled_vocabulary_term_id: predicate.value.id,
      value: inputValue.value
    })
      .then((response) => {
        TW.workbench.alert.create(
          'Data attribute(s) were successfully created',
          'notice'
        )
        resetForm()
        emit('create', response.body)
      })
      .catch(() => {})
  }
}
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
