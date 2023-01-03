<template>
  <FacetContainer>
    <h3>Biological relationships</h3>
    <div class="field">
      <SmartSelector
        model="biological_relationships"
        @selected="addBiologicalRelationship"
      />
      <DisplayList
        :list="biologicalRelationships"
        label="object_tag"
        :warning-message="false"
        :delete-warning="false"
        @delete="removeBiologicalRelationship"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { BiologicalRelationship } from 'routes/endpoints'
import { ref, computed, watch } from 'vue'
import { removeFromArray } from 'helpers/arrays'

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
  set: value => emit('update:modelValue', value)
})

watch(
  () => params.value.biological_relationship_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      biologicalRelationships.value = []
    }
  }
)

watch(
  biologicalRelationships,
  newVal => {
    params.value.biological_relationship_id = newVal.map(item => item.id)
  }
)

function addBiologicalRelationship (item) {
  biologicalRelationships.value.push(item)
}

function removeBiologicalRelationship (biologicalRelationship) {
  removeFromArray(biologicalRelationships.value, biologicalRelationship)
}

const { biological_relationship_id = [] } = URLParamsToJSON(location.href)

biological_relationship_id.forEach(id => {
  BiologicalRelationship.find(id).then(({ body }) => {
    addBiologicalRelationship(body)
  })
})

</script>
