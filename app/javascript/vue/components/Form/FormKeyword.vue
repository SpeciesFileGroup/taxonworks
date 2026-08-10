<template>
  <form
    @submit="emitCVT"
    class="label-above"
  >
    <div class="field">
      <label>Name</label>
      <input
        class="full_width"
        type="text"
        required
        v-model="controlledVocabularyTerm.name"
      />
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
      />
    </div>

    <div class="field">
      <label>Uri</label>
      <input
        type="text"
        class="full_width"
        v-model="controlledVocabularyTerm.uri"
      />
    </div>

    <div class="flex-separate">
      <VBtn
        medium
        color="create"
        type="submit"
      >
        {{ controlledVocabularyTerm.id ? 'Update' : 'Create' }}
      </VBtn>
      <VBtn
        medium
        color="primary"
        variant="tonal"
        @click="newCVT"
      >
        New
      </VBtn>
    </div>
  </form>
</template>

<script setup>
import { computed } from 'vue'
import makeControlledVocabularyTerm from '@/factory/controlledVocabularyTerm.js'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => makeControlledVocabularyTerm()
  }
})

const DEFINITION_MIN_LENGTH = 20

const emit = defineEmits(['submit', 'update:modelValue', 'new'])

const controlledVocabularyTerm = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

function emitCVT(e) {
  e.preventDefault()
  emit('submit', controlledVocabularyTerm.value)
}

function newCVT() {
  const data = makeControlledVocabularyTerm()

  controlledVocabularyTerm.value = data
  emit('new', data)
}
</script>
