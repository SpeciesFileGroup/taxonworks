<template>
  <FacetContainer>
    <h3>Nomenclatural scope</h3>
    <div>
      <autocomplete
        url="/taxon_names/autocomplete"
        param="term"
        label="label_html"
        clear-after
        placeholder="Search a taxon name"
        @get-item="setTaxon($event.id)"
      />
      <SmartSelectorItem
        v-if="taxon"
        :item="taxon"
        label="object_tag"
        @unset="removeTaxon"
      />
      <div class="field separate-top">
        <label>
          <input
            type="checkbox"
            name="taxon-validity"
            v-model="params.citations_on_otus"
          >
          Citations on OTUs
        </label>
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import Autocomplete from 'components/ui/Autocomplete'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'
import { computed, ref, onBeforeMount } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const taxon = ref()

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  if (urlParams.ancestor_id) {
    setTaxon(urlParams.ancestor_id)
  }
  params.value.citations_on_otus = urlParams?.citations_on_otus
})

const setTaxon = id => {
  TaxonName.find(id).then(response => {
    taxon.value = response.body
    params.value.ancestor_id = response.body.id
  })
}

const removeTaxon = () => {
  taxon.value = undefined
  params.value.ancestor_id = undefined
}
</script>
