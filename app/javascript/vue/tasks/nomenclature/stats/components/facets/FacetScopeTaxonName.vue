<template>
  <FacetContainer>
    <h3>Taxon name</h3>
    <SmartSelector
      model="taxon_names"
      pin-section="TaxonNames"
      pin-type="TaxonName"
      :autocomplete-params="{ 'type[]': 'Protonym' }"
      @selected="selectTaxonName"
    />
    <template v-if="taxonName">
      <div
        class="separate-top"
        v-html="taxonName.object_tag"
      />
      <VBtn
        v-if="parentIsSupported"
        class="separate-top"
        color="primary"
        medium
        @click="selectTaxonName(taxonName.parent)"
      >
        Set to {{ taxonName.parent.object_label }}
      </VBtn>
    </template>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { TaxonName } from '@/routes/endpoints'

const props = defineProps({
  taxonName: {
    type: Object,
    default: undefined
  },

  supportedRanks: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select'])

const parentIsSupported = computed(() => {
  const parent = props.taxonName?.parent

  return !!parent && props.supportedRanks.includes(rankNameFor(parent))
})

function rankNameFor(parent) {
  return parent.rank_string?.split('::').pop().toLowerCase()
}

function selectTaxonName({ id }) {
  TaxonName.find(id, { extend: ['parent'] }).then(({ body }) => {
    if (props.supportedRanks.includes(body.rank)) {
      emit('select', body)
    } else {
      TW.workbench.alert.create(
        'Please choose a taxon with a governed code of nomenclature.',
        'alert'
      )
    }
  })
}
</script>
