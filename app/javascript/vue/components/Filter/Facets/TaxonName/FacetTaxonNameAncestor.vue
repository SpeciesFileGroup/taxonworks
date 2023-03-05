<template>
  <FacetContainer>
    <h3>Taxon name</h3>
    <div class="field">
      <SmartSelector
        model="taxon_names"
        @selected="taxon = $event"
      />
      <SmartSelectorItem
        :item="taxon"
        label="object_tag"
        @unset="taxon = undefined"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'
import { ref, computed, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const taxon = ref(undefined)
const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

watch(
  taxon,
  newVal => {
    params.value.ancestor_id = newVal?.id
  }
)

watch(() => params.value.ancestor_id, newVal => {
  if (!newVal) {
    taxon.value = undefined
  }
})

const { ancestor_id } = URLParamsToJSON(location.href)

if (ancestor_id) {
  TaxonName.find(ancestor_id).then(({ body }) => {
    taxon.value = body
  })
}

</script>
