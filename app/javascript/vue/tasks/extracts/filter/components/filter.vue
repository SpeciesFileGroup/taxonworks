<template>
  <div
    class="panel vue-filter-container"
    v-hotkey="shortcuts">
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
      <extract-origin-facet
        class="margin-large-bottom"
        v-model="params.base.extract_origin"
      />
      <collection-object-facet
        class="margin-large-bottom"
        v-model="params.base.collection_object_id"
      />
      <taxon-name-facet
        class="margin-large-bottom"
        v-model="params.taxon"
      />
      <otu-facet
        class="margin-large-bottom"
        v-model="params.base.otu_id"
        target="Extract"
      />
      <extract-verbatim-anatomical-facet
        class="margin-large-bottom"
        v-model="params.verbatimAnatomical"
      />
      <with-component
        class="margin-large-bottom"
        title="Sequences"
        param="sequences"
        v-model="params.base.sequences"
      />
      <date-range-facet
        class="margin-large-bottom"
        v-model:start="params.extract_start_date_range"
        v-model:end="params.extract_end_date_range"
      />
      <repository-component
        class="margin-large-bottom"
        v-model="params.repository.repository_id"
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
      <protocol-facet
        class="margin-large-bottom"
        v-model="params.protocols"
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
import RepositoryComponent from 'tasks/collection_objects/filter/components/filters/repository.vue'
import ProtocolFacet from './filters/ProtocolFacet.vue'
import OtuFacet from './filters/OtuFacet.vue'
import TaxonNameFacet from './filters/TaxonNameFacet.vue'
import DateRangeFacet from './filters/DateRangeFacet.vue'
import CollectionObjectFacet from './filters/CollectionObjectFacet.vue'
import ExtractOriginFacet from './filters/ExtractOriginFacet.vue'
import ExtractVerbatimAnatomicalFacet from './filters/ExtractVerbatimAnatomicalFacet.vue'
import KeywordsComponent from 'tasks/sources/filter/components/filters/tags'
import platformKey from 'helpers/getPlatformKey.js'
import WithComponent from 'tasks/sources/filter/components/filters/with'
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
    ...params.value.keywords,
    ...params.value.protocols,
    ...params.value.taxon,
    ...params.value.verbatimAnatomical,
    ...filterEmptyParams(params.value.user)
  })
)

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  base: {
    collection_object_id: [],
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
