<template>
  <FacetContainer>
    <h3
      data-help="Number of slots on each axis. Containers without a value for a filtered axis are excluded. To find an exact size set both values to the same number."
    >
      Size
    </h3>
    <div
      v-for="bound in BOUNDS"
      :key="bound.param"
      class="field label-above"
    >
      <label>{{ bound.label }}</label>
      <div class="horizontal-left-content gap-small">
        <div
          v-for="axis in AXES"
          :key="axis"
          class="field"
        >
          <label class="d-block capitalize">{{ axis }}</label>
          <input
            v-model="params[`size_${axis}_${bound.param}`]"
            type="number"
            min="0"
            class="input-xsmall-width"
          />
        </div>
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const AXES = ['x', 'y', 'z']

const BOUNDS = [
  { label: 'Minimum', param: 'min' },
  { label: 'Maximum', param: 'max' }
]

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
