<template>
  <FacetContainer>
    <h3>Collection objects</h3>
    <smart-selector
      model="collection_objects"
      klass="Extract"
      @selected="addToArray(collectionObjects, $event)"
    />
    <display-list
      :list="collectionObjects"
      label="object_tag"
      :delete-warning="false"
      soft-delete
      @delete="removeFromArray(collectionObjects, $event)"
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { addToArray, removeFromArray } from 'helpers/arrays'
import { URLParamsToJSON } from 'helpers/url/parse'
import { CollectionObject } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const emit = defineEmits(['update:modelValue'])

const collectionObjects = ref([])
const { collection_object_id: coIds } = URLParamsToJSON(location.href)

if (coIds) {
  Promise
    .all(coIds.map(id => CollectionObject.find(id)))
    .then(responses => {
      collectionObjects.value = responses.map(r => r.body)
    })
}

watch(
  collectionObjects,
  newVal => { params.value.collection_object_id = newVal.map(co => co.id) },
  { deep: true }
)

watch(
  () => props.modelValue,
  (newVal, oldVal) => {
    if (!newVal?.collection_object_id?.length && oldVal?.collection_object_id?.length) {
      collectionObjects.value = []
    }
  }
)

</script>
