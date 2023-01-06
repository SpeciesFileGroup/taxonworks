<template>
  <FacetWith
    title="In project"
    :options="IN_PROJECT_OPTIONS"
    param="in_project"
    v-model="params"
  />
  <FacetTitle v-model="params" />
  <FacetSourceType v-model="params" />
  <FacetAuthors v-model="params" />
  <FacetDate v-model="params" />
  <FacetSerials v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetTags
    v-model="params"
    target="Source"
  />
  <FacetBibtexType v-model="params" />
  <FacetCitationTopics v-model="params" />
  <FacetIdentifiers v-model="params" />
  <FacetNomenclaturalScope v-model="params" />
  <FacetCitationTypes v-model="params" />
  <FacetUsers v-model="params" />
  <FacetSomeValue
    model="sources"
    label="cached"
    v-model="params"
  />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="WITH_TITLES[param] || param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>
import { computed } from 'vue'
import FacetTitle from 'components/Filter/Facets/Source/FacetTitle.vue'
import FacetAuthors from 'components/Filter/Facets/Source/FacetAuthors.vue'
import FacetDate from 'components/Filter/Facets/Source/FacetDate.vue'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetCitationTypes from 'components/Filter/Facets/Source/FacetCitationTypes'
import FacetSerials from 'components/Filter/Facets/Source/FacetSerials.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetSourceType from 'components/Filter/Facets/Source/FacetSourceType'
import FacetCitationTopics from 'components/Filter/Facets/Source/FacetCitationTopics'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetSomeValue from 'components/Filter/Facets/shared/FacetSomeValue.vue'
import FacetNomenclaturalScope from 'components/Filter/Facets/Source/FacetNomenclaturalScope.vue'
import FacetMatchIdentifiers from 'components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import FacetBibtexType from 'components/Filter/Facets/Source/FacetBibtexType.vue'

const WITH_TITLES = {
  with_title: 'BibTeX title'
}

const IN_PROJECT_OPTIONS = [
  {
    label: 'Both',
    value: undefined
  },
  {
    label: 'Yes',
    value: true
  },
  {
    label: 'No',
    value: false
  }
]

const WITH_PARAMS = [
  'citations',
  'roles',
  'documents',
  'nomenclature',
  'with_doi',
  'tags',
  'notes',
  'serial',
  'with_title'
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
