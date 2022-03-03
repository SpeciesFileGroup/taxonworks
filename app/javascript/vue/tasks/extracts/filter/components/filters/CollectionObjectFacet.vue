<template>
  <div>
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
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { addToArray, removeFromArray } from 'helpers/arrays'
import { URLParamsToJSON } from 'helpers/url/parse'
import { CollectionObject } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  }
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
  newVal => { emit('update:modelValue', newVal.map(co => co.id)) },
  { deep: true }
)

watch(
  () => props.modelValue,
  (newVal, oldVal) => {
    if (!newVal.length && oldVal.length) {
      collectionObjects.value = []
    }
  }
)

</script>
