<template>
  <v-btn
    medium
    color="primary"
    :disabled="!ids.length"
    @click="emit('update:modelValue', allSelected ? [] : ids)"
  >
    {{
      allSelected
        ? 'Unselect all'
        : 'Select all'
    }}
  </v-btn>
</template>

<script setup>

import { computed } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  ids: {
    type: Array,
    required: true
  },

  modelValue: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const allSelected = computed(() => props.ids.length === props.modelValue.length)

</script>
