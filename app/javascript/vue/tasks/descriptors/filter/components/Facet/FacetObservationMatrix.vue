<template>
  <FacetContainer>
    <h3>Observation matrix</h3>
    <SmartSelector
      model="observation_matrices"
      @selected="addObservationMatrix"
    />
    <DisplayList
      :list="observationMatrices"
      label="name"
      soft-delete
      :warning="false"
      @delete="removeFromArray(observationMatrices, $event)"
    />
  </FacetContainer>
</template>

<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList'
import { ObservationMatrix } from 'routes/endpoints'
import { removeFromArray } from 'helpers/arrays.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => {
    emit('update:modelValue', value)
  }
})

const observationMatrices = ref([])

function addObservationMatrix (matrix) {
  observationMatrices.value.push(matrix)
}

watch(
  () => params.value.observation_matrix_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      observationMatrices.value = []
    }
  }
)

watch(
  observationMatrices,
  newVal => {
    params.value.observation_matrix_id = newVal.map(item => item.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  const ids = params.value.observation_matrix_id || []

  ids.forEach(id => {
    ObservationMatrix.find(id).then(({ body }) => {
      addObservationMatrix(body)
    })
  })
})
</script>
