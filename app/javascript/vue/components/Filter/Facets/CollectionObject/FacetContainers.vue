<template>
  <FacetContainer>
    <h3>Containers</h3>
    <VAutocomplete
      url="/containers/autocomplete"
      placeholder="Search a container..."
      param="term"
      label="label_html"
      display="label"
      clear-after
      :excluded-ids="list.map((container) => container.id)"
      @get-item="addContainer($event.id)"
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
import { Container } from '@/routes/endpoints'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const params = defineModel({
  type: Object,
  required: true
})

const list = ref([])
const containerIds = [params.value.container_id || []].flat()

if (containerIds.length) {
  Container.all({ container_id: containerIds })
    .then(({ body }) => {
      list.value = body
    })
    .catch(() => {})
}

const addContainer = (id) => {
  Container.find(id)
    .then(({ body }) => {
      addToArray(list.value, body)
    })
    .catch(() => {})
}

watch(
  list,
  (newVal) => {
    params.value.container_id = newVal.map((container) => container.id)
  },
  { deep: true }
)

watch(
  () => params.value.container_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      list.value = []
    }
  }
)
</script>

<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
