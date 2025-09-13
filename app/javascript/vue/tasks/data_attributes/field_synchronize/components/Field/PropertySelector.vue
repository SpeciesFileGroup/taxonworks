<template>
  <div>
    <label class="d-block">Attribute</label>
    <select v-model="selected">
      <option
        selected
        :value="selected"
      >
        Select...
      </option>
      <option
        v-for="property in list"
        :key="property"
      >
        {{ property }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  properties: {
    type: Array,
    default: () => []
  },

  modelValue: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const selected = computed({
  get: () => props.modelValue,
  set: (value) => {
    emit('update:modelValue', [...props.modelValue, value])
  }
})

const list = computed(() =>
  props.properties.filter((property) => !selected.value?.includes(property))
)
</script>
