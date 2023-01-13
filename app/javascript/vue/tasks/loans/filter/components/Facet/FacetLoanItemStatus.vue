<template>
  <FacetContainer>
    <h3>Status</h3>
    <select v-model="params.loan_item_disposition ">
      <option :value="undefined">
        All
      </option>
      <option
        v-for="status in STATUS_LIST"
        :key="status"
        :value="status"
      >
        {{ status }}
      </option>
    </select>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import STATUS_LIST from 'tasks/loans/new/const/status.js'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
