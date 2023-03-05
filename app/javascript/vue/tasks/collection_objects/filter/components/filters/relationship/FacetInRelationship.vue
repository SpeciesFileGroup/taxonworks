<template>
  <FacetContainer>
    <h3>In relationship</h3>
    <div class="separate-bottom">
      <ul
        v-if="biologicalRelationships.length"
        class="no_bullets"
      >
        <li
          v-for="item in biologicalRelationships"
          :key="item.id"
        >
          <label>
            <input
              :value="item.id"
              v-model="relationshipSelected"
              type="checkbox"
            />
            {{
              item.inverted_name
                ? `${item.name} / ${item.inverted_name}`
                : item.name
            }}
          </label>
        </li>
      </ul>
      <a
        v-else
        href="/tasks/biological_relationships/composer"
      >
        Create new
      </a>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { BiologicalRelationship } from 'routes/endpoints'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const biologicalRelationships = ref([])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const relationshipSelected = computed({
  get: () => props.modelValue || [],
  set: (value) => {
    params.value.biological_relationship_id = value
  }
})

onBeforeMount(() => {
  BiologicalRelationship.all().then((response) => {
    biologicalRelationships.value = response.body
  })
  const urlParams = URLParamsToJSON(location.href)

  params.value.biological_relationship_id =
    urlParams.biological_relationship_id || []
})
</script>
