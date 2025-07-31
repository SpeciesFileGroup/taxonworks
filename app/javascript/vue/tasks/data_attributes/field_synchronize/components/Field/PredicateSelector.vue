<template>
  <div>
    <label class="d-block">Predicate</label>
    <select v-model="selected">
      <option
        selected
        :value="selected"
      >
        Select...
      </option>
      <option
        v-for="predicate in list"
        :key="predicate.id"
        :value="predicate"
      >
        {{ predicate.name }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  predicates: {
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
  props.predicates.filter(
    (predicate) => !selected.value?.some(({ id }) => predicate.id === id)
  )
)
</script>
