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
      <facet-person
        class="margin-large-bottom"
        v-model="params.base"
      />
      <FacetActiveYear v-model="params.base" />
      <FacetBorn v-model="params.base" />
      <FacetDied v-model="params.base" />
      <with-component
        class="margin-large-bottom"
        title="Sequences"
        param="sequences"
        v-model="params.with"
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
import KeywordsComponent from 'tasks/sources/filter/components/filters/tags'
import platformKey from 'helpers/getPlatformKey.js'
import WithComponent from 'tasks/sources/filter/components/filters/with'
import FacetPerson from './Facet/FacetPerson.vue'
import FacetActiveYear from 'tasks/uniquify/people/components/Filter/Facets/FacetActive.vue'
import FacetBorn from 'tasks/uniquify/people/components/Filter/Facets/FacetBorn.vue'
import FacetDied from 'tasks/uniquify/people/components/Filter/Facets/FacetDied.vue'
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
    ...params.value.base,
    ...params.value.with,
    ...filterEmptyParams(params.value.user)
  })
)

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  base: {
    name: undefined,
    last_name: undefined,
    first_name: undefined,
    suffix: undefined,
    prefix: undefined,
    exact: [],
    near_name: undefined,
    levenshtein_cuttoff: 1,
    regex: undefined,
    with_role: [],
    without_role: [],
    role_total_min: undefined,
    role_total_max: undefined,
    born_after_year: undefined,
    active_after_year: undefined,
    active_before_year: undefined,
    died_after_year: undefined,
    repeated_total: undefined
  },
  with: {
    first_name: undefined,
    last_name: undefined
  },
  user: {
    user_id: undefined,
    user_target: undefined,
    user_date_start: undefined,
    user_date_end: undefined
  },
  identifier: {
    identifier: undefined,
    identifier_exact: undefined,
    identifier_start: undefined,
    identifier_end: undefined,
    namespace_id: undefined
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
