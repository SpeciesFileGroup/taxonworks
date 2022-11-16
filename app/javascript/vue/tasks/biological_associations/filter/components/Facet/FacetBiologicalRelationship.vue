<template>
  <div>
    <h3>Biological relationships</h3>
    <div class="field">
      <smart-selector
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
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { BiologicalRelationship } from 'routes/endpoints'
import { ref, computed, watch } from 'vue'
import { removeFromArray } from 'helpers/arrays'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const biologicalRelationships = ref([])
const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  params,
  newVal => {
    if (!newVal.length) {
      biologicalRelationships.value = []
    }
  }
)

function addBiologicalRelationship (item) {
  params.value.push(item.id)
  biologicalRelationships.value.push(item)
}

function removeBiologicalRelationship (biologicalRelationship) {
  const index = params.value.findIndex(item => item.id === biologicalRelationship.id)

  removeFromArray(biologicalRelationships.value, biologicalRelationship)
  params.value.splice(index, 1)
}

const { biological_relationship_id = [] } = URLParamsToJSON(location.href)

biological_relationship_id.forEach(id => {
  BiologicalRelationship.find(id).then(({ body }) => {
    addBiologicalRelationship(body)
  })
})

</script>
