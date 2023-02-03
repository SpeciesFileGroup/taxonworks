<template>
  <ul>
    <li
      class="horizontal-left-content middle qualitative-descriptor__descriptor-li"
      v-for="characterState in descriptor.characterStates"
      :key="characterState.id"
    >
      <label class="margin-small-right middle">
        <input
          type="checkbox"
          v-model="observation.characterStateId"
          :value="characterState.id"
        >
        {{ characterState.label }}: {{ characterState.name }}
      </label>
    </li>
  </ul>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  descriptor: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const observation = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
