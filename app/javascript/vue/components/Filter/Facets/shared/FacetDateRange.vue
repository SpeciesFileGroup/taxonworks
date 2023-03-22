<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start date</label>
        <br />
        <input
          type="date"
          v-model="params[`start_${param}`]"
        />
      </div>

      <div class="field">
        <label>End date</label>
        <br />
        <input
          type="date"
          v-model="params[`end_${param}`]"
        />
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  title: {
    type: String,
    default: 'Date range'
  },

  param: {
    type: String,
    required: true
  }
})

const emit = defineEmits('update:modelValue')

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
