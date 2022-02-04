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
        class="button button-default normal-input full_width"
        type="button"
        :disabled="isParamsEmpty"
        @click="handleSearch">
        Search
      </button>
      <otu-component
        v-model="params.determination"
      />
      <geographic-component
        class="margin-large-bottom margin-medium-top"
        v-model="params.geographic"/>
      <repository-component
        class="margin-large-bottom"
        v-model="params.repository.repository_id"
      />
      <identifier-component
        class="margin-large-bottom"
        v-model="params.identifier"
      />
      <user-component
        class="margin-large-bottom"
        v-model="params.user"/>
    </div>
  </div>
</template>

<script setup>

import UserComponent from './filters/user'
import GeographicComponent from './filters/geographic'
import IdentifierComponent from './filters/identifier'
import RepositoryComponent from './filters/repository.vue'
import OtuComponent from 'tasks/collection_objects/filter/components/filters/otu.vue'
import platformKey from 'helpers/getPlatformKey.js'
import { URLParamsToJSON } from 'helpers/url/parse.js'
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
    ...filterEmptyParams(params.value.user)
  })
)

const isParamsEmpty = computed(() => !(
  params.value.geographic.geographic_area_id?.length ||
  params.value.geographic.geo_json?.length ||
  params.value.repository.repository_id ||
  params.value.determination.otu_ids.length ||
  params.value.determination.determiner_id.length ||
  params.value.determination.ancestor_id ||
  Object.values(params.value.user).find(item => item) ||
  Object.values(params.value.identifier).find(item => item)
))

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  urlParams.geo_json = urlParams.geo_json ? JSON.stringify(urlParams.geo_json) : []
}

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  determination: {
    determiner_id_or: [],
    determiner_id: [],
    otu_ids: [],
    current_determinations: undefined,
    ancestor_id: undefined,
    validity: undefined
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
