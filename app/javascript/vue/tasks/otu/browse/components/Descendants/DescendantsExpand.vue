<template>
  <button
    type="button"
    :title="isExpanded ? 'Close' : 'Expand'"
    class="button-expand"
    @click="isExpanded = !isExpanded"
  >
    <svg
      v-if="isExpanded"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      stroke-width="2"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M15 12H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
    <svg
      v-else
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      stroke-width="2"
      class="icon-size"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const isExpanded = computed({
  get() {
    return props.modelValue
  },

  set(value) {
    emit('update:modelValue', value)
  }
})
</script>

<style scoped>
.button-expand {
  position: absolute;
  width: 1.25rem;
  height: 1.25rem;
  left: -0.625rem;
  padding: 0px;
  color: var(--color-primary);
  background: var(--color-panel);
  border: none;
  outline: none;
  box-shadow: none;
  z-index: 2;
}

svg {
  width: 1.25rem;
  height: 1.25rem;
}
</style>
