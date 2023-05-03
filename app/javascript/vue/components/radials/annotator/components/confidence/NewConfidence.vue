<template>
  <div>
    <input
      class="full_width margin-small-bottom"
      type="text"
      v-model="confidence.name"
      placeholder="Name"
    >
    <textarea
      class="separate-bottom"
      placeholder="Definition... (minimum is 20 characters)"
      v-model="confidence.definition"
    />
    <div>
      <button
        @click="submit({ confidence_level_attributes: confidence })"
        :disabled="!validateFields"
        class="button button-submit normal-input separate-bottom"
        type="button"
      >
        Create
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'

const emit = defineEmits(['submit'])

const validateFields = computed(() =>
  confidence.value.name &&
  confidence.value.definition
)

const confidence = ref(newConfidence())

function newConfidence () {
  return {
    name: '',
    definition: ''
  }
}

function submit (payload) {
  emit('submit', payload)
  confidence.value = newConfidence()
}

</script>
