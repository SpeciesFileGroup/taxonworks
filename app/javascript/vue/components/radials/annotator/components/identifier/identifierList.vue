<template>
  <div class="field">
    <ul class="no_bullets">
      <li
        v-for="(_, key) in list"
        :key="key"
      >
        <label class="capitalize">
          <input
            type="radio"
            v-model="type"
            :value="key"
          >
          {{ key }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  list: {
    type: Object,
    default: () => ({})
  },

  modelValue: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const type = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
</script>
