<template>
  <div
    class="panel vue-filter-container"
    v-hotkey="shortcuts"
  >
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <button
        type="button"
        data-icon="w_reset"
        class="button circle-button button-default center-icon no-margin"
        @click="resetFilter"
      />
    </div>

    <div class="content">
      <button
        class="button button-default normal-input full_width margin-medium-bottom "
        type="button"
        @click="handleSearch"
      >
        Search
      </button>
      <FacetCollectingEvent v-model="params.base.collecting_event_id" />
      <FacetTaxonName
        class="margin-large-bottom"
        v-model="params.taxon_name_id"
      />
      <FacetOtu
        class="margin-large-bottom"
        v-model="params.base.otu_id"
        target="Extract"
      />
      <with-component
        class="margin-large-bottom"
        title="Sequences"
        param="sequences"
        v-model="params.base.sequences"
      />
      <FacetMatchIdentifiers
        class="margin-large-bottom"
        v-model="params.matchIdentifiers"
      />
      <keywords-component
        class="margin-large-bottom"
        v-model="params.keywords"
        target="CollectionObject"
      />
      <identifier-component
        class="margin-large-bottom"
        v-model="params.identifier"
      />
      <user-component
        class="margin-large-bottom"
        v-model="params.user"
      />
    </div>
  </div>
</template>

<script setup>

import UserComponent from 'tasks/collection_objects/filter/components/filters/user'
import IdentifierComponent from 'tasks/collection_objects/filter/components/filters/identifier'
import FacetMatchIdentifiers from 'tasks/people/filter/components/Facet/FacetMatchIdentifiers.vue'
import KeywordsComponent from 'tasks/sources/filter/components/filters/tags'
import platformKey from 'helpers/getPlatformKey.js'
import WithComponent from 'tasks/sources/filter/components/filters/with'
import checkMatchIdentifiersParams from 'tasks/people/filter/helpers/checkMatchIdentifiersParams'
import FacetCollectingEvent from './Facet/FacetCollectingEvent.vue'
import FacetTaxonName from './Facet/FacetTaxonName.vue'
import FacetOtu from 'tasks/extracts/filter/components/filters/OtuFacet'
import { computed, ref } from 'vue'

const emit = defineEmits([
  'parameters',
  'reset'
])

const shortcuts = computed(() => {
  const keys = {}

  keys[`${platformKey()}+r`] = resetFilter
  keys[`${platformKey()}+f`] = handleSearch

  return keys
})

const parseParams = computed(() =>
  ({
    ...params.value.determination,
    ...params.value.identifier,
    ...params.value.geographic,
    ...params.value.repository,
    ...params.value.base,
    ...params.value.date,
    ...params.value.keywords,
    ...params.value.protocols,
    ...params.value.taxon,
    ...params.value.verbatimAnatomical,
    ...checkMatchIdentifiersParams(params.value.matchIdentifiers),
    ...filterEmptyParams(params.value.user)
  })
)

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  base: {
    collection_object_ids: [],
    collecting_event_id: [],
    extract_origin: undefined,
    sequences: undefined,
    otu_id: []
  },
  identifier: {
    identifier: undefined,
    identifier_exact: undefined,
    identifier_start: undefined,
    identifier_end: undefined,
    namespace_id: undefined
  },
  user: {
    user_id: undefined,
    user_target: undefined,
    user_date_start: undefined,
    user_date_end: undefined
  },
  geographic: {
    geo_json: [],
    radius: undefined,
    spatial_geographic_areas: undefined,
    geographic_area_id: []
  },
  matchIdentifiers: {
    match_identifiers: undefined,
    match_identifiers_delimiter: ',',
    match_identifiers_type: 'internal'
  },
  repository: {
    repository_id: undefined
  },
  date: {
    extract_start_date_range: undefined,
    extract_end_date_range: undefined
  },
  keywords: {
    keyword_id_and: [],
    keyword_id_or: []
  },
  taxon: {
    ancestor_id: undefined
  },
  protocols: {
    protocol_id_and: [],
    protocol_id_or: []
  },
  verbatimAnatomical: {
    verbatim_anatomical_origin: undefined,
    exact_verbatim_anatomical_origin: undefined
  }
})

const params = ref(initParams())

const handleSearch = () => {
  emit('parameters', parseParams.value)
}

const filterEmptyParams = object => {
  const keys = Object.keys(object)

  keys.forEach(key => {
    if (object[key] === '') {
      delete object[key]
    }
  })
  return object
}

</script>
<style scoped>
:deep(.btn-delete) {
    background-color: #5D9ECE;
  }
</style>
