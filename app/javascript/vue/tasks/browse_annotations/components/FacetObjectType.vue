<template>
  <FacetContainer v-if="Object.keys(usedOn).length">
    <h3>Object type</h3>
    <ul class="no_bullets">
      <li
        v-for="(label, key) in usedOn"
        :key="key"
      >
        <label>
          <input
            type="radio"
            :value="key"
            name="annotation-object-type"
            v-model="selectedType"
          />
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  usedOn: {
    type: Object,
    default: () => ({})
  },

  paramName: {
    type: String,
    required: true
  }
})

const params = defineModel({
  type: Object,
  required: true
})

const selectedType = computed({
  get: () => {
    const val = params.value[props.paramName]
    return Array.isArray(val) ? val[0] : val
  },
  set: (value) => {
    params.value = {
      ...params.value,
      [props.paramName]: [value]
    }
  }
})
</script>
