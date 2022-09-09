<template>
  <div class="panel vue-filter-container">
    <div
      class="flex-separate content middle action-line"
      v-hotkey="shortcuts"
    >
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        @click="resetFilter"
      >Reset
      </span>
    </div>
    <div class="content">
      <button
        class="button button-default normal-input full_width"
        type="button"
        :disabled="emptyParams"
        @click="handleSearch"
      >
        Search
      </button>
      <WithComponent
        class="margin-large-bottom margin-medium-top"
        title="In project"
        name="params.source.in_project"
        :values="['Both', 'Yes', 'No']"
        param="in_project"
        v-model="params.source.in_project"
      />
      <TitleComponent
        class="margin-large-bottom"
        v-model="params.source"
      />
      <TypeComponent
        class="margin-large-bottom"
        v-model="params.source.source_type"
      />
      <AuthorsComponent
        class="margin-large-bottom"
        v-model="params.source"
      />
      <DateComponent
        class="margin-large-bottom"
        v-model="params.source"
      />
      <SerialsComponent
        class="margin-large-bottom"
        v-model="params.source.serial_ids"
      />
      <FacetMatchIdentifiers
        class="margin-large-bottom"
        v-model="params.matchIdentifiers"
      />
      <TagsComponent
        class="margin-large-bottom"
        v-model="params.keywords"
        target="Source"
      />
      <TopicsComponent
        class="margin-large-bottom"
        v-model="params.source.topic_ids"
      />
      <IdentifierComponent
        class="margin-large-bottom"
        v-model="params.identifier"
      />
      <TaxonNameComponent
        class="margin-large-bottom"
        v-model="params.nomenclature"
      />
      <CitationTypesComponent
        class="margin-large-bottom"
        v-model="params.source.citation_object_type"
      />
      <UsersComponent
        class="margin-large-bottom"
        v-model="params.user"
      />
      <SomeValueComponent
        class="margin-large-bottom"
        model="sources"
        label="cached"
        v-model="params.attributes"
      />
      <WithComponent
        class="margin-large-bottom"
        v-for="(item, key) in params.byRecordsWith"
        :key="key"
        :title="key"
        :param="key"
        v-model="params.byRecordsWith[key]"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { removeEmptyProperties } from 'helpers/objects'
import TitleComponent from './filters/title'
import platformKey from 'helpers/getPlatformKey.js'
import AuthorsComponent from './filters/authors'
import DateComponent from './filters/date'
import TagsComponent from './filters/tags'
import IdentifierComponent from './filters/identifiers'
import CitationTypesComponent from './filters/citationTypes'
import SerialsComponent from './filters/serials'
import WithComponent from './filters/with'
import TypeComponent from './filters/type'
import TopicsComponent from './filters/topics'
import UsersComponent from 'tasks/collection_objects/filter/components/filters/user'
import SomeValueComponent from './filters/SomeValue/SomeValue'
import TaxonNameComponent from './filters/TaxonName'
import FacetMatchIdentifiers from 'tasks/people/filter/components/Facet/FacetMatchIdentifiers.vue'
import checkMatchIdentifiersParams from 'tasks/people/filter/helpers/checkMatchIdentifiersParams'
import vHotkey from 'plugins/v-hotkey'

const extend = ['documents']

const parseAttributeParams = (attributes) => ({
  empty: attributes.filter(item => item.empty).map(item => item.name),
  not_empty: attributes.filter(item => !item.empty).map(item => item.name)
})

const emptyParams = computed(() => {
  if (!params.value) return
  return !params.value
})

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
    ...checkMatchIdentifiersParams(params.value.matchIdentifiers),
    ...parseAttributeParams(params.value.attributes),
    ...params.value.source,
    ...params.value.keywords,
    ...params.value.byRecordsWith,
    ...params.value.nomenclature,
    ...params.value.identifier,
    ...params.value.user,
    extend
  })
)

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  extend,
  source: {
    author_ids_or: undefined,
    query_term: undefined,
    author: undefined,
    exact_author: undefined,
    author_ids: [],
    year_start: undefined,
    year_end: undefined,
    title: undefined,
    year: undefined,
    exact_title: undefined,
    in_project: true,
    source_type: undefined,
    citation_object_type: [],
    topic_ids: [],
    users: [],
    serial_ids: []
  },
  keywords: {
    keyword_id_and: [],
    keyword_id_or: []
  },
  attributes: [],
  byRecordsWith: {
    citations: undefined,
    roles: undefined,
    documents: undefined,
    nomenclature: undefined,
    with_doi: undefined,
    tags: undefined,
    notes: undefined
  },
  identifier: {
    namespace_id: undefined,
    identifier: undefined,
    identifiers_start: undefined,
    identifiers_end: undefined,
    identifier_exact: undefined
  },
  matchIdentifiers: {
    match_identifiers: undefined,
    match_identifiers_delimiter: ',',
    match_identifiers_type: 'internal'
  },
  nomenclature: {
    ancestor_id: undefined,
    citations_on_otus: undefined
  },
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
