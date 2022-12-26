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
      <FacetNomenclatureRelation
        v-model:object="params.base.object_taxon_name_id"
        v-model:subject="params.base.subject_taxon_name_id"
        v-model:both="params.base.taxon_name_id"
      />
      <FacetGeographic v-model="params.geographic" />

      <FacetWKT v-model="params.base.wkt" />
      <FacetBiologicalRelationship
        v-model="params.base.biological_relationship_id"
        class="margin-large-bottom"
      />
      <FacetBiologicalProperty
        v-model:object="params.base.object_biological_property_id"
        v-model:subject="params.base.subject_biological_property_id"
      />
      <FacetOtu
        class="margin-large-bottom"
        v-model="params.base.otu_id"
        target="BiologicalAssociation"
      />
      <FacetCollectionObject v-model="params.base.collection_object_id" />
      <FacetCollectingEvent v-model="params.base.collecting_event_id" />
      <FacetBiologicalProperty
        v-model:object="params.base.object_biological_property_id"
        v-model:subject="params.base.subject_biological_property_id"
      />
      <FacetNotes v-model="params.notes" />
      <FacetIdentifier
        class="margin-large-bottom"
        v-model="params.identifier"
      />
      <keywords-component
        class="margin-large-bottom"
        v-model="params.keywords"
        target="CollectionObject"
      />
      <user-component
        class="margin-large-bottom"
        v-model="params.user"
      />
      <WithComponent
        class="margin-large-bottom"
        v-for="(_, key) in params.with"
        :key="key"
        :title="key"
        :param="key"
        v-model="params.with[key]"
      />
    </div>
  </div>
</template>

<script setup>
import FacetGeographic from 'components/Filter/Facets/shared/FacetGeographic.vue'
import FacetWKT from 'tasks/otu/filter/components/Facet/FacetWKT.vue'
import UserComponent from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetIdentifier from 'tasks/collection_objects/filter/components/filters/identifier'
import FacetBiologicalRelationship from './Facet/FacetBiologicalRelationship.vue'
import KeywordsComponent from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetNotes from 'tasks/collection_objects/filter/components/filters/FacetNotes.vue'
import FacetCollectionObject from 'tasks/extracts/filter/components/filters/CollectionObjectFacet.vue'
import platformKey from 'helpers/getPlatformKey.js'
import checkMatchIdentifiersParams from 'tasks/people/filter/helpers/checkMatchIdentifiersParams'
import FacetCollectingEvent from './Facet/FacetCollectingEvent.vue'
import FacetBiologicalProperty from './Facet/FacetBiologicalProperty.vue'
import FacetNomenclatureRelation from './Facet/FacetNomenclatureRelation.vue'
import FacetOtu from 'tasks/extracts/filter/components/filters/OtuFacet'
import WithComponent from 'components/Filter/Facets/shared/FacetWith.vue'
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
    ...params.value.base,
    ...params.value.notes,
    ...params.value.keywords,
    ...params.value.with,
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
    collection_object_id: [],
    collecting_event_id: [],
    otu_id: [],
    biological_relationship_id: [],
    subject_biological_property_id: [],
    object_biological_property_id: [],
    object_taxon_name_id: [],
    subject_taxon_name_id: [],
    taxon_name_id: [],
    wkt: undefined
  },
  identifier: {
    identifier: undefined,
    identifier_exact: undefined,
    identifier_start: undefined,
    identifier_end: undefined,
    namespace_id: undefined
  },
  geographic: {
    geo_json: [],
    radius: undefined,
    geographic_area_mode: undefined,
    geographic_area_id: []
  },
  user: {
    user_id: undefined,
    user_target: undefined,
    user_date_start: undefined,
    user_date_end: undefined
  },
  notes: {
    note_exact: undefined,
    note_text: undefined
  },
  matchIdentifiers: {
    match_identifiers: undefined,
    match_identifiers_delimiter: ',',
    match_identifiers_type: 'internal'
  },
  keywords: {
    keyword_id_and: [],
    keyword_id_or: []
  },
  with: {
    citations: undefined
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
