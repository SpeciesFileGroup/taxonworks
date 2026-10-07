<template>
  <FacetContainer>
    <h3>Asserted environment object type</h3>
    <ul class="no_bullets">
      <li
        v-for="type in objectTypes"
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
import { ref, watch } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { AssertedEnvironment } from '@/routes/endpoints'

const objectTypes = ref([])

AssertedEnvironment.objectTypes().then(({ body }) => {
  objectTypes.value = body
})

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
