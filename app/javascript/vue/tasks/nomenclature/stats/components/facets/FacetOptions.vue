<template>
  <FacetContainer>
    <h3>Options</h3>
    <ul class="no_bullets context-menu">
      <li>
        <label>
          <input
            type="checkbox"
            v-model="params.combinations"
          />
          Combinations
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
