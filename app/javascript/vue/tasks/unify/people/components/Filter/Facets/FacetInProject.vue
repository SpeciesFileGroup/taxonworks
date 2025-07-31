<template>
  <FacetContainer>
    <h3>Referenced in project</h3>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in options"
        :key="key"
      >
        <label>
          <input
            type="radio"
            v-model="params.only_project_id"
            :value="value"
          />
          {{ key }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { getCurrentProjectId } from '@/helpers/project.js'

const params = defineModel({
  type: Object,
  required: true
})

const options = {
  Any: undefined,
  Current: [getCurrentProjectId()]
}
</script>
