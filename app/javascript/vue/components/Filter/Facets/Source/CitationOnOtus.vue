<template>
  <div class="field separate-top">
    <label>
      <input
        type="checkbox"
        name="taxon-validity"
        v-model="params.citations_on_otus"
      />
      Citations on OTUs
    </label>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
