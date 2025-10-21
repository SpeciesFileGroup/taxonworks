<template>
  <FacetContainer>
    <h3>Anatomical parts</h3>
    <SmartSelector
      model="anatomical_parts"
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
import { ref, watch } from 'vue'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { AnatomicalPart } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  includes: { // currently unused
    type: Boolean,
    default: false
  }
})

const params = defineModel({
  type: Object,
  required: true
})

const list = ref([])
const anatomicalPartIds = params.value.field_occurrence_id || []

if (anatomicalPartIds.length) {
  AnatomicalPart.all({ anatomical_part_id: anatomicalPartIds })
    .then(({ body }) => {
      list.value = body
    })
    .catch(() => {})
}

watch(
  list,
  (newVal) => {
    params.value.anatomical_part_id = newVal.map((part) => part.id)
  },
  { deep: true }
)

watch(
  () => params.value.anatomical_part_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      list.value = []
    }
  }
)
</script>
