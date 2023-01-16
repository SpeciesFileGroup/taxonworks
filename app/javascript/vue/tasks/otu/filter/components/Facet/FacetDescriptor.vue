<template>
  <FacetContainer>
    <h3>Descriptors</h3>
    <VAutocomplete
      url="/descriptors/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search a descriptor"
      clear-after
      @get-item="addDescriptor($event.id)"
    />
    <DisplayList
      :list="descriptors"
      label="object_tag"
      :delete-warning="false"
      @delete="removeDescriptor"
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import { Descriptor } from 'routes/endpoints'
import { removeFromArray, addToArray } from 'helpers/arrays'
import VAutocomplete from 'components/ui/Autocomplete.vue'
import DisplayList from 'components/displayList.vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])
const descriptors = ref([])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  () => params.value.descriptor_id,
  (newVal, oldVal) => {
    if (!newVal.length && oldVal?.length) {
      descriptors.value = []
    }
  },
  { deep: true }
)

watch(
  descriptors,
  newVal => {
    params.value.descriptor_id = newVal.map(d => d.id)
  },
  { deep: true }
)

function addDescriptor (id) {
  Descriptor.find(id).then(({ body }) => {
    addToArray(descriptors.value, body)
  })
}

function removeDescriptor (descriptor) {
  removeFromArray(descriptors.value, descriptor)
}

onBeforeMount(() => {
  params.value.descriptor_id?.forEach(id => {
    addDescriptor(id)
  })
})

</script>
