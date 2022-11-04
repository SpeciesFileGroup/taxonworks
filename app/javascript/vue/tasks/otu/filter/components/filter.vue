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
      <FacetGeographicArea
        class="margin-large-bottom"
        v-model="params.geographic"
        input-id="area_picker_autocomplete"
      />
      <FacetWKT
        class="margin-large-bottom"
        v-model="params.base.wkt"
      />
      <FacetCollectingEvent
        v-model="params.base.collecting_event_id"
      />
      <FacetTaxonName
        class="margin-large-bottom"
        v-model="params.base"
      />
      <FacetBiologicalRelationship
        class="margin-large-bottom"
        v-model="params.base.biological_relationship_id"
      />
      <taxon-name-component
        v-model="params.base.taxon_name_ids"
        class="margin-large-bottom"
      />
      <author-component
        v-model="params.author"
        class="margin-large-bottom"
      />
      <citations-component
        title="Citations"
        v-model="params.base.citations"
        class="margin-large-bottom"
      />
      <with-component
        v-for="(_, key) in params.with"
        :key="key"
        :title="key"
        v-model="params.with[key]"
        class="margin-small-bottom"
      />
    </div>
  </div>
</template>

<script setup>
import { removeEmptyProperties } from 'helpers/objects'
import { computed, ref } from 'vue'
import platformKey from 'helpers/getPlatformKey.js'
import vHotkey from 'plugins/v-hotkey.js'
import FacetTaxonName from 'tasks/extracts/filter/components/filters/TaxonNameFacet.vue'
import FacetGeographicArea from 'tasks/collection_objects/filter/components/filters/geographic'
import CitationsComponent from 'tasks/nomenclature/filter/components/filters/citations'
import WithComponent from 'tasks/observation_matrices/dashboard/components/filters/with'
import FacetWKT from './filters/Facet/FacetWKT.vue'
import FacetBiologicalRelationship from 'tasks/biological_associations/filter/components/Facet/FacetBiologicalRelationship.vue'
import FacetCollectingEvent from 'tasks/biological_associations/filter/components/Facet/FacetCollectingEvent.vue'

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
  removeEmptyProperties({
    ...params.value.base,
    ...params.value.geographic,
    ...params.value.with
  })
)

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  settings: {
    per: 500,
    page: 1
  },
  base: {
    taxon_name_ids: [],
    biological_association_ids: [],
    biological_relationship_id: [],
    asserted_distribution_ids: [],
    data_attributes_attributes: [],
    collecting_event_id: [],
    citations: undefined,
    wkt: undefined,
    ancestor_id: undefined
  },
  geographic: {
    geo_json: [],
    radius: undefined,
    spatial_geographic_areas: undefined,
    geographic_area_id: []
  },
  with: {
    biological_associations: undefined,
    asserted_distributions: undefined,
    daterminations: undefined,
    depictions: undefined,
    observations: undefined
  }
})

const params = ref(initParams())

const handleSearch = () => {
  emit('parameters', parseParams.value)
}

</script>

<style scoped>
:deep(.btn-delete) {
  background-color: #5D9ECE;
}
</style>
