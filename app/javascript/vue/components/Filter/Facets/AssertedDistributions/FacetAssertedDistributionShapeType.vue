<template>
  <FacetContainer>
    <h3>Asserted Distribution shape type</h3>
    <ul class="no_bullets">
      <li
        v-for="type in SHAPE_TYPES"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="params.asserted_distribution_shape_type"
          />
          {{ type }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { watch } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const SHAPE_TYPES = [
  'GeographicArea',
  'Gazetteer'
]

const params = defineModel({type: Object, required: true})

watch(params, (newVal) => {
  if (!Array.isArray(newVal.asserted_distribution_shape_type)) {
    params.value.asserted_distribution_shape_type = []
  }
},
{ immediate: true }
)

</script>
