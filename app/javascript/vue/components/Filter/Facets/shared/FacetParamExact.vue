<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <div class="field label-above">
      <label
        v-if="label"
        class="capitalize"
        >{{ label }}</label
      >
      <input
        class="full_width"
        :name="param"
        type="text"
        v-model="params[param]"
      />
      <label>
        <input
          v-model="params[`${param}_exact`]"
          type="checkbox"
          :name="`${param}_exact`"
        />
        Exact
      </label>
      <label
        v-for="item in aditionalCheckboxes"
        :key="item.param"
      >
        <input
          v-model="params[item.param]"
          type="checkbox"
          :name="item.param"
        />
        {{ item.label }}
      </label>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  title: {
    type: String,
    required: true
  },

  param: {
    type: String,
    required: true
  },

  label: {
    type: String,
    default: ''
  },

  aditionalCheckboxes: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
