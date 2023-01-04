<template>
  <FacetNameAuthorYear v-model="params" />
  <FacetPrecision v-model="params" />
  <FacetAuthors v-model="params" />
  <FacetTaxonName
    :autocomplete-params="{
      type: 'Protonym',
      valid: true
    }"
    include
    v-model="params"
  />
  <FacetNomenclatureGroup v-model="params" />
  <FacetNomenclatureCode v-model="params" />
  <FacetValidity v-model="params" />
  <FacetTaxonNameType v-model="params" />
  <FacetRelationships v-model="params" />
  <FacetStatus v-model="params" />
  <FacetInRelationship v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetTags
    target="TaxonName"
    v-model="params"
  />
  <FacetUsers v-model="params" />
  <FacetUpdatedSince v-model="params" />
  <FacetCitations v-model="params" />
  <FacetDataAttribute v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :param="param"
    :title="(WITH_TITLES[param] && WITH_TITLES[param].title) || param.replaceAll('_', ' ')"
    :inverted="WITH_TITLES[param] && WITH_TITLES[param].inverted"
    v-model="params"
  />
</template>

<script setup>

import FacetNameAuthorYear from './filters/FacetNameAuthorYear.vue'
import FacetPrecision from './filters/FacetPrecision.vue'
import FacetUpdatedSince from './filters/FacetUpdatedSince'
import FacetValidity from './filters/FacetValidity.vue'
import FacetCitations from 'components/Filter/Facets/Citations/FacetCitations.vue'
import FacetRelationships from './filters/FacetRelationships.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetStatus from './filters/FacetStatus.vue'
import FacetNomenclatureGroup from './filters/FacetNomenclatureGroup.vue'
import FacetNomenclatureCode from './filters/FacetNomenclatureCode.vue'
import FacetInRelationship from './filters/FacetInRelationship'
import FacetTaxonNameType from './filters/FacetTaxonNameType.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetAuthors from './filters/FacetAuthors.vue'
import FacetDataAttribute from 'components/Filter/Facets/shared/FacetDataAttribute.vue'
import FacetMatchIdentifiers from 'components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import { computed } from 'vue'

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
  'leaves',
  'data_attributes',
  'type_metadata',
  'otus',
  'authors',
  'etymology',
  'not_specified'
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
  set: value => emit('update:modelValue', value)
})

</script>
