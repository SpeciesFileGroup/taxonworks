<template>
  <FacetContainer>
    <h3>Match list against</h3>
    <ul class="no_bullets">
      <li
        v-for="option in OPTIONS"
        :key="option.value"
      >
        <label>
          <input
            :value="option.value"
            v-model="params.validity"
            type="radio"
          />
          {{ option.label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const OPTIONS = [
  {
    label: 'All names',
    value: undefined
  },
  {
    label: 'Only valid names',
    value: true
  },
  {
    label: 'Only invalid names',
    value: false
  }
]

const params = defineModel({
  type: Object,
  required: true
})
</script>
