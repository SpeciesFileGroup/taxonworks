<template>
  <FacetParamExact
    v-model="params"
    param="name"
    title="Name"
    :aditional-checkboxes="[
      {
        label: 'Epithet only',
        param: 'epithet_only'
      }
    ]"
  />
  <FacetTaxonName
    :autocomplete-params="{
      type: 'Protonym',
      valid: true
    }"
    include
    v-model="params"
  />
  <FacetAuthors v-model="params" />
  <FacetDateYear v-model="params" />
  <FacetNomenclatureGroup v-model="params" />
  <FacetNomenclatureCode v-model="params" />
  <FacetValidity v-model="params" />
  <FacetTaxonNameType v-model="params" />
  <FacetRelationships v-model="params" />
  <FacetStatus v-model="params" />
  <FacetRelationToRelationship v-model="params" />
  <FacetInRelationship v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetTags
    :target="TAXON_NAME"
    v-model="params"
  />
  <FacetConfidence
    v-model="params"
    :target="TAXON_NAME"
  />
  <FacetUsers v-model="params" />
  <FacetUpdatedSince v-model="params" />
  <FacetDataAttribute v-model="params" />
  <FacetImportAttribute v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :param="param"
    :title="
      (WITH_TITLES[param] && WITH_TITLES[param].title) ||
      param.replaceAll('_', ' ')
    "
    :inverted="WITH_TITLES[param] && WITH_TITLES[param].inverted"
    v-model="params"
  />
  <FacetValidify v-model="params" />
  <FacetCombinationify v-model="params" />
  <FacetSynonymify v-model="params" />
  <FacetAncestrify v-model="params" />
  <FacetDiffModel v-model="params" />
</template>

<script setup>
import FacetUpdatedSince from './filters/FacetUpdatedSince'
import FacetValidity from './filters/FacetValidity.vue'
import FacetRelationships from './filters/FacetRelationships.vue'
import FacetTaxonName from '@/components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetStatus from './filters/FacetStatus.vue'
import FacetNomenclatureGroup from './filters/FacetNomenclatureGroup.vue'
import FacetNomenclatureCode from './filters/FacetNomenclatureCode.vue'
import FacetInRelationship from './filters/FacetInRelationship'
import FacetTaxonNameType from './filters/FacetTaxonNameType.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetValidify from './filters/FacetValidify.vue'
import FacetCombinationify from './filters/FacetCombinationify.vue'
import FacetSynonymify from './filters/FacetSynonymify.vue'
import FacetAncestrify from '@/components/Filter/Facets/shared/FacetAncestrify.vue'
import FacetAuthors from './filters/FacetAuthors.vue'
import FacetDataAttribute from '@/components/Filter/Facets/shared/FacetDataAttribute/FacetDataAttribute.vue'
import FacetMatchIdentifiers from '@/components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import FacetDateYear from '@/components/Filter/Facets/Source/FacetDate.vue'
import FacetParamExact from '@/components/Filter/Facets/shared/FacetParamExact.vue'
import FacetImportAttribute from '@/components/Filter/Facets/shared/FacetImportAttribute/FacetImportAttribute.vue'
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetConfidence from '@/components/Filter/Facets/shared/FacetConfidence.vue'
import FacetRelationToRelationship from './filters/FacetRelationToRelationship.vue'
import { computed } from 'vue'
import { TAXON_NAME } from '@/constants'

const WITH_TITLES = {
  type_metadata: {
    title: 'Type information'
  },
  not_specified: {
    title: 'Incomplete combination relationships'
  },
  leaves: {
    title: 'Descendants',
    inverted: true
  }
}

const WITH_PARAMS = [
  'authors',
  'citation_documents',
  'citations',
  'combinations',
  'confidences',
  'data_attributes',
  'data_depictions',
  'depictions',
  'leaves', // 'Descendants'
  'etymology',
  'global_identifiers',
  'not_specified', // 'Incomplete combination relationships'
  'latinized',
  'local_identifiers',
  'nomenclature_date',
  'notes',
  'origin_citation',
  'original_combination',
  'otus',
  'tags',
  'type_metadata', // 'Type information'
  'verbatim_name'
]

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
