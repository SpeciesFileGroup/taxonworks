<template>
  <FacetContainer>
    <h3>Preparation type</h3>
    <div class="field">
      <SmartSelector
        model="preparation_types"
        klass="preparation_types"
        :target="target"
        @selected="(item) => addToArray(preparationTypes, item)"
      />
    </div>
    <DisplayList
      v-if="preparationTypes.length"
      :list="preparationTypes"
      label="object_tag"
      :delete-warning="false"
      soft-delete
      @delete="(item) => removeFromArray(preparationTypes, item)"
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { PreparationType } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  target: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const preparationTypes = ref([])

const params = computed({
  get: () => props.modelValue,
  set: (value) => {
    emit('update:modelValue', value)
  }
})

watch(
  () => props.modelValue.preparation_type_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      preparationTypes.value = []
    }
  }
)

watch(
  preparationTypes,
  (newVal) => {
    params.value.preparation_type_id = newVal.map((preparation_type) => preparation_type.id)
  },
  { deep: true }
)

const preparationTypeIds = params.value.preparation_type_id || []

if (preparationTypeIds.length) {
  Preparation.all({ preparation_type_id: preparationTypeIds })
    .then(({ body }) => {
      preparationTypes.value = body
    })
    .catch(() => {})
}
</script>

<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
