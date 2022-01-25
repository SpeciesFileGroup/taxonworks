<template>
  <form
    @submit="emitCVT"
    class="label-above">
    <div class="field">
      <label>Name</label>
      <input
        class="full_width"
        type="text"
        required
        v-model="controlledVocabularyTerm.name"
      >
    </div>

    <div class="field">
      <label>Definition</label>
      <textarea
        class="full_width"
        :placeholder="`Definition (minimum length ${DEFINITION_MIN_LENGTH} characters)`"
        :minlength="DEFINITION_MIN_LENGTH"
        rows="5"
        required
        v-model="controlledVocabularyTerm.definition"
      />
    </div>

    <div class="field">
      <label>Label color</label>
      <input
        type="color"
        v-model="controlledVocabularyTerm.css_color"
      >
    </div>

    <div class="field">
      <label>Uri</label>
      <input
        type="text"
        class="full_width"
        v-model="controlledVocabularyTerm.uri"
      >
    </div>

    <div class="flex-separate">
      <button
        type="submit"
        class="button normal-input button-submit"
      >
        {{ controlledVocabularyTerm.id ? 'Update' : 'Create' }}
      </button>
      <button
        type="button"
        class="button normal-input button-default"
        @click="newCTV">
        New
      </button>
    </div>
  </form>
</template>

<script setup>
import { computed } from 'vue'
import makeControlledVocabularyTerm from 'factory/controlledVocabularyTerm.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => makeControlledVocabularyTerm()
  }
})

const DEFINITION_MIN_LENGTH = 20

const emit = defineEmits([
  'submit',
  'update:modelValue'
])

const controlledVocabularyTerm = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const emitCVT = e => {
  e.preventDefault()
  emit('submit', controlledVocabularyTerm.value)
}
</script>
