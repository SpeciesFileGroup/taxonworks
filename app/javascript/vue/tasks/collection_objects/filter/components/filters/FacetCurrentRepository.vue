<template>
  <FacetContainer>
    <h3>Current repository</h3>
    <SmartSelector
      v-model="repositorySelected"
      model="repositories"
      klass="CollectionObject"
      pin-section="Repositories"
      pin-type="Repository"
      @selected="setRepository"
    />
    <SmartSelectorItem
      v-if="repositorySelected"
      :item="repositorySelected"
      label="name"
      @unset="unsetRepository"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Repository } from 'routes/endpoints'
import { computed, ref, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  () => params.value.current_repository_id,
  id => {
    if (!id) {
      unsetRepository()
    }
  },
  { deep: true }
)

const repositorySelected = ref(undefined)

const setRepository = (repository) => {
  repositorySelected.value = repository
  params.value.current_repository_id = repository.id
}

const unsetRepository = () => {
  repositorySelected.value = undefined
  params.value.current_repository_id = undefined
}

const urlParams = URLParamsToJSON(location.href)

if (urlParams.current_repository_id) {
  Repository.find(urlParams.current_repository_id).then(response => {
    setRepository(response.body)
  })
}

</script>

<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
