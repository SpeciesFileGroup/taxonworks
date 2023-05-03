<template>
  <div>
    <div class="field separate-top">
      <input
        class="normal-input full_width"
        placeholder="Identifier"
        type="text"
        v-model="identifier"
      >
    </div>
    <button
      type="button"
      class="button normal-input button-submit separate-bottom"
      :disabled="!identifier || !type"
      @click="emitCreate"
    >
      Create
    </button>
  </div>
</template>

<script setup>
import { ref } from 'vue'

defineProps({
  type: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['create'])
const identifier = ref(null)

const emitCreate = () => {
  emit('create', {
    identifier: identifier.value
  })
}
</script>
