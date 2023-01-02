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
import { computed, ref, watch } from 'vue'
import { Descriptor } from 'routes/endpoints'
import { removeFromArray } from 'helpers/arrays'
import { URLParamsToJSON } from 'helpers/url/parse'
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

const descriptorIds = computed({
  get: () => params.value.descriptor_id || [],
  set: value => { params.value.descriptor_id = value }
})

watch(
  () => descriptorIds,
  newVal => {
    if (!newVal.length) {
      descriptors.value = []
    }
  },
  { deep: true }
)

function addDescriptor (id) {
  if (descriptorIds.value.includes(id)) return

  Descriptor.find(id).then(({ body }) => {
    descriptors.value.push(body)
    descriptorIds.value.push(body.id)
  })
}

function removeDescriptor (descriptor) {
  const index = descriptorIds.value.findIndex(item => item.id === descriptor.id)

  removeFromArray(descriptors.value, descriptor)
  descriptorIds.value.splice(index, 1)
}

const { descriptor_id = [] } = URLParamsToJSON(location.href)

descriptor_id.forEach(id => {
  addDescriptor(id)
})

</script>
