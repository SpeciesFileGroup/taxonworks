<template>
  <FacetContainer>
    <h3>Repository</h3>
    <SmartSelector
      v-model="repositorySelected"
      model="repositories"
      klass="CollectionObject"
      pin-section="Repositories"
      pin-type="Repository"
      @selected="setRepository"
    />
    <SmartSelectorItem
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
import { computed, ref, watch, onBeforeMount } from 'vue'

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
  () => props.modelValue.repository_id,
  () => {
    repositorySelected.value = undefined
  }
)

const repositorySelected = ref()

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.repository_id = urlParams.repository_id

  if (urlParams.repository_id) {
    Repository.find(urlParams.repository_id).then(response => {
      setRepository(response.body)
    })
  }
})

const setRepository = repository => {
  repositorySelected.value = repository
  params.value.repository_id = repository.id
}

const unsetRepository = () => {
  repositorySelected.value = undefined
  params.value.repository_id = undefined
}
</script>

<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
