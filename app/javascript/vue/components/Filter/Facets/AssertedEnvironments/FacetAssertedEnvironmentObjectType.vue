<template>
  <FacetContainer>
    <h3>Asserted environment object type</h3>
    <ul class="no_bullets">
      <li
        v-for="type in OBJECT_TYPES"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="params.asserted_environment_object_type"
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
import { OTU, COLLECTING_EVENT, GAZETTEER } from '@/constants'

// AssertedEnvironment's object types (see ENVIRONMENT_ASSERTABLE_TYPES on the
// server) - kept in sync by hand, there being no server-driven facet options
// list to read this from at build time.
const OBJECT_TYPES = [OTU, COLLECTING_EVENT, GAZETTEER]

const params = defineModel({ type: Object, required: true })

watch(
  params,
  (newVal) => {
    if (!Array.isArray(newVal.asserted_environment_object_type)) {
      params.value.asserted_environment_object_type = []
    }
  },
  { immediate: true }
)
</script>
