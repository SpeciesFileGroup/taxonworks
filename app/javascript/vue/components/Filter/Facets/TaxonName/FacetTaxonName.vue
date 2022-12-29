<template>
  <FacetContainer>
    <h3>Taxon name</h3>
    <div class="field">
      <SmartSelector
        model="taxon_names"
        @selected="addTaxonName"
      />
      <DisplayList
        :list="taxonNames"
        label="object_tag"
        :delete-warning="false"
        @delete="removeTaxonName"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'
import { ref, computed, watch } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'
import { removeFromArray } from 'helpers/arrays.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const taxonNames = ref([])
const taxonNameIds = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  taxonNameIds,
  (newVal) => {
    if (!newVal.length) {
      taxonNames.value = []
    }
  },
  { deep: true }
)

function addTaxonName (taxonName) {
  if (taxonNameIds.value.includes(taxonName.id)) return

  taxonNames.value.push(taxonName)
  taxonNameIds.value.push(taxonName.id)
}

function removeTaxonName (taxonName) {
  const index = taxonNameIds.value.findIndex(item => item.id === taxonName.id)

  removeFromArray(taxonNames.value, taxonName)
  taxonNameIds.value.splice(index, 1)
}

const { taxon_name_id = [] } = URLParamsToJSON(location.href)

taxon_name_id.forEach(id => {
  TaxonName.find(id).then(({ body }) => {
    addTaxonName(body)
  })
})

</script>
