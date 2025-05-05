<template>
  <FacetContainer>
    <h3>Field occurrences</h3>
    <SmartSelector
      model="field_occurrences"
      @selected="addToArray(list, $event)"
    />
    <DisplayList
      :list="list"
      label="object_tag"
      :delete-warning="false"
      soft-delete
      @delete="removeFromArray(list, $event)"
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { FieldOccurrence } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const emit = defineEmits(['update:modelValue'])

const list = ref([])
const foIds = params.value.field_occurrence_id || []

if (foIds.length) {
  FieldOccurrence.all({ field_occurrence_id: foIds }).then(({ body }) => {
    list.value = body
  })
}

watch(
  list,
  (newVal) => {
    params.value.field_occurrence_id = newVal.map((co) => co.id)
  },
  { deep: true }
)

watch(
  () => props.modelValue,
  (newVal, oldVal) => {
    if (
      !newVal?.field_occurrence_id?.length &&
      oldVal?.field_occurrence_id?.length
    ) {
      list.value = []
    }
  }
)
</script>
