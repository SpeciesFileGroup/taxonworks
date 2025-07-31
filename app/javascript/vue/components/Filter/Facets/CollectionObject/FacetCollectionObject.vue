<template>
  <FacetContainer>
    <h3>Collection objects</h3>
    <SmartSelector
      model="collection_objects"
      klass="Extract"
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
import { computed, ref, watch } from 'vue'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { CollectionObject } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import Includes from './components/Includes.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  includes: {
    type: Boolean,
    default: false
  }
})

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const emit = defineEmits(['update:modelValue'])

const list = ref([])
const coIds = params.value.collection_object_id || []

if (coIds.length) {
  CollectionObject.all({ collection_object_id: coIds }).then(({ body }) => {
    list.value = body
  })
}

watch(
  list,
  (newVal) => {
    params.value.collection_object_id = newVal.map((co) => co.id)
  },
  { deep: true }
)

watch(
  () => props.modelValue,
  (newVal, oldVal) => {
    if (
      !newVal?.collection_object_id?.length &&
      oldVal?.collection_object_id?.length
    ) {
      list.value = []
    }
  }
)
</script>
