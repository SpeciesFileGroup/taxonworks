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
    <Includes
      v-if="includes"
      v-model="params"
    />
  </FacetContainer>
</template>

<script setup>
import { ref, watch } from 'vue'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { FieldOccurrence } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import Includes from './components/Includes.vue'

const props = defineProps({
  includes: {
    type: Boolean,
    default: false
  }
})

const params = defineModel({
  type: Object,
  required: true
})

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
    params.value.field_occurrence_id = newVal.map((fo) => fo.id)
  },
  { deep: true }
)

watch(
  () => params.value.field_occurrence_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      list.value = []
    }
  }
)
</script>
