<template>
  <FacetContainer>
    <h3>Classification scope</h3>
    <label>Taxon name</label>
    <autocomplete
      url="/taxon_names/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search for a taxon name"
      clear-after
      :add-params="autocompleteParams"
      @get-item="setTaxon($event.id)"
    />
    <SmartSelectorItem
      v-if="selectedTaxon"
      label="object_tag"
      :item="selectedTaxon"
      @unset="removeTaxon"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import Autocomplete from 'components/ui/Autocomplete'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'
import { ref, computed, watch, onBeforeMount } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  autocompleteParams: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const selectedTaxon = ref()

watch(
  () => props.modelValue.taxon_name_id,
  newVal => {
    if (!newVal?.length) {
      selectedTaxon.value = undefined
    }
  }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  if (urlParams.taxon_name_id) {
    setTaxon(urlParams.taxon_name_id[0])
  }
})

const setTaxon = id => {
  TaxonName.find(id).then(({ body }) => {
    selectedTaxon.value = body
    params.value.taxon_name_id = [body.id]
  })
}
const removeTaxon = () => {
  selectedTaxon.value = undefined
  params.value.taxon_name_id = []
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%
}
</style>
