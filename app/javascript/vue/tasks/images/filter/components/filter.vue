<template>
  <div class="panel vue-filter-container">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        v-hotkey="shortcuts"
        @click="resetFilter"
      >
        Reset
      </span>
    </div>
    <div class="content">
      <button
        class="button button-default normal-input full_width"
        type="button"
        @click="handleSearch"
      >
        Search
      </button>
      <otus-component
        class="margin-large-bottom"
        v-model="params.base.otu_id"
      />
      <scope-component
        class="margin-large-bottom"
        v-model="params.base.taxon_name_id"
      />
      <ancestor-target
        class="margin-large-bottom"
        v-model="params.base.ancestor_id_target"
        :taxon-name="params.base.taxon_name_id"
      />
      <collection-object-component
        class="margin-large-bottom"
        v-model="params.base.collection_object_id"
      />
      <biocurations-component
        class="margin-large-bottom"
        v-model="params.base.biocuration_class_id"
      />
      <identifier-component
        class="margin-large-bottom"
        v-model="params.identifier"
      />
      <tags-component
        class="margin-large-bottom"
        target="Image"
        v-model="params.keywords"
      />
      <users-component
        class="margin-large-bottom"
        v-model="params.user"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { removeEmptyProperties } from 'helpers/objects'
import platformKey from 'helpers/getPlatformKey.js'
import UsersComponent from 'components/Filter/Facets/shared/FacetUsers.vue'
import BiocurationsComponent from 'tasks/collection_objects/filter/components/filters/biocurations'
import TagsComponent from 'components/Filter/Facets/shared/FacetTags.vue'
import IdentifierComponent from 'tasks/collection_objects/filter/components/filters/identifier'
import ScopeComponent from 'tasks/nomenclature/filter/components/filters/scope'
import OtusComponent from './filters/otus'
import CollectionObjectComponent from './filters/collectionObjects'
import AncestorTarget from './filters/ancestorTarget'
import vHotkey from 'plugins/v-hotkey'

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
    ...params.value.identifier,
    ...params.value.depictions,
    ...params.value.keywords,
    ...params.value.base,
    ...params.value.user,
    ...params.value.settings
  })
)

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  settings: {
    per: 50,
    page: 1
  },
  base: {
    otu_id: [],
    taxon_name_id: [],
    biocuration_class_id: [],
    collection_object_id: [],
    ancestor_id_target: undefined
  },
  identifier: {
    identifier: undefined,
    identifier_exact: undefined,
    identifier_start: undefined,
    identifier_end: undefined,
    namespace_id: undefined
  },
  keywords: {
    keyword_id_and: [],
    keyword_id_or: []
  },
  depictions: {},
  collectingEvent: {},
  collectionObject: {},
  nomenclature: {},
  user: {
    user_id: undefined,
    user_target: undefined,
    user_date_start: undefined,
    user_date_end: undefined
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
