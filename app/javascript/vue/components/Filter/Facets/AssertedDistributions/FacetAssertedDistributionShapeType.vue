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
            v-model="params.shape_type"
          />
          {{ type }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const SHAPE_TYPES = [
  'GeographicArea',
  'Gazetteer'
]

const params = defineModel({type: Object, required: true})
if (!params.value.shape_type) {
  params.value.shape_type = []
}

</script>
