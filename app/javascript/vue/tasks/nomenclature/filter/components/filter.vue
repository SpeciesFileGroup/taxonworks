<template>
  <div class="panel vue-filter-container">
    <div class="flex-separate content middle action-line">
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
        v-hotkey="shortcuts"
        @click="handleSearch"
      >
        Search
      </button>
      <taxon-name-component
        class="margin-medium-bottom"
        v-model="params.taxon"
      />
      <precision-component
        class="margin-medium-bottom"
        v-model="params.base.exact"
      />
      <authors-component
        class="margin-medium-bottom"
        v-model="params.authors"
      />
      <scope-component
        class="margin-medium-bottom"
        :autocomplete-params="{
          type: 'Protonym',
          valid: true
        }"
        v-model="params.base.taxon_name_id"
      />
      <related-component
        class="margin-medium-bottom"
        v-model="params.includes"
        :taxon-name="params.base.taxon_name_id"
      />
      <rank-component
        class="margin-medium-bottom"
        v-model="params.base.nomenclature_group"
      />
      <code-component
        class="margin-medium-bottom"
        v-model="params.base.nomenclature_code"
      />
      <validity-component
        class="margin-medium-bottom"
        v-model="params.base.validity"
      />
      <taxon-name-type-component
        class="margin-medium-bottom"
        v-model="params.base.taxon_name_type"
      />
      <relationships-component
        class="margin-medium-bottom"
        v-model="params.base.taxon_name_relationship"
        :nomenclature-code="params.base.nomenclature_code"
      />
      <status-component
        class="margin-medium-bottom"
        v-model="params.base.taxon_name_classification"
        :nomenclature-code="params.base.nomenclature_code"
      />
      <in-relationship-component
        class="margin-medium-bottom"
        v-model="params.base.taxon_name_relationship_type"
        :nomenclature-code="params.base.nomenclature_code"
      />
      <FacetMatchIdentifiers
        class="margin-medium-bottom"
        v-model="params.matchIdentifiers"
      />
      <tags-component
        class="margin-medium-bottom"
        target="TaxonName"
        v-model="params.keywords"
      />
      <users-component
        class="margin-medium-bottom"
        v-model="params.user"
      />
      <updated-component
        class="margin-medium-bottom"
        v-model="params.base.updated_since"
      />
      <citations-component
        class="margin-medium-bottom"
        v-model="params.base.citations"
      />
      <FacetDataAttribute
        class="margin-medium-bottom"
        v-model="params.dataAttributes"
      />
      <with-component
        v-for="(param, key) in params.with"
        :key="key"
        :param="key"
        :title="(withTitles[key] && withTitles[key].title) || key.replaceAll('_', ' ')"
        :inverted="withTitles[key] && withTitles[key].inverted"
        v-model="params.with[key]"
      />
    </div>
  </div>
</template>

<script setup>

import TaxonNameComponent from './filters/name'
import PrecisionComponent from './filters/precision.vue'
import UpdatedComponent from './filters/updated'
import ValidityComponent from './filters/validity'
import RelatedComponent from './filters/related'
import CitationsComponent from './filters/citations'
import RelationshipsComponent from './filters/relationships'
import ScopeComponent from './filters/scope'
import StatusComponent from './filters/status'
import RankComponent from './filters/nomenclature_group'
import CodeComponent from './filters/nomenclature_code'
import InRelationshipComponent from './filters/in_relationship'
import TaxonNameTypeComponent from './filters/taxon_name_type'
import UsersComponent from 'components/Filter/Facets/shared/FacetUsers.vue'
import TagsComponent from 'components/Filter/Facets/shared/FacetTags.vue'
import WithComponent from 'components/Filter/Facets/shared/FacetWith.vue'
import AuthorsComponent from './filters/authors.vue'
import FacetDataAttribute from 'tasks/collection_objects/filter/components/filters/DataAttributes/FacetDataAttribute.vue'
import FacetMatchIdentifiers from 'components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import checkMatchIdentifiersParams from 'tasks/people/filter/helpers/checkMatchIdentifiersParams'
import platformKey from 'helpers/getPlatformKey.js'
import { removeEmptyProperties } from 'helpers/objects'
import { computed, ref } from 'vue'

const withTitles = {
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
    ...params.value.taxon,
    ...params.value.dataAttributes,
    ...params.value.authors,
    ...params.value.with,
    ...params.value.keywords,
    ...params.value.related,
    ...params.value.base,
    ...params.value.user,
    ...params.value.includes,
    extend: ['parent'],
    updated_since: params.value.updated_since
      ? setDays(params.value.updated_since)
      : undefined
  })
)

const resetFilter = () => {
  emit('reset')
  params.value = initParams()
}

const initParams = () => ({
  authors: {
    taxon_name_author_ids: [],
    taxon_name_author_ids_or: undefined
  },
  taxon: {
    name: undefined,
    author: undefined,
    year: undefined
  },
  with: {
    leaves: undefined,
    data_attributes: undefined,
    type_metadata: undefined,
    otus: undefined,
    authors: undefined,
    etymology: undefined,
    not_specified: undefined
  },
  base: {
    citations: undefined,
    validity: undefined,
    taxon_name_type: undefined,
    exact: undefined,
    updated_since: undefined,
    descendants: undefined,
    nomenclature_group: undefined,
    nomenclature_code: undefined,
    taxon_name_id: [],
    taxon_name_relationship: [],
    taxon_name_relationship_type: [],
    taxon_name_classification: []
  },
  matchIdentifiers: {
    match_identifiers: undefined,
    match_identifiers_delimiter: ',',
    match_identifiers_type: 'internal'
  },
  dataAttributes: {
    data_attribute_value: [],
    data_attribute_predicate_id: [],
    data_attribute_exact: undefined
  },
  keywords: {
    keyword_id_and: [],
    keyword_id_or: []
  },
  includes: {
    descendants: undefined,
    ancestors: undefined
  },
  user: {
    user_id: undefined,
    user_target: undefined,
    user_date_start: undefined
  }
})

const params = ref(initParams())

const handleSearch = () => {
  emit('parameters', parseParams.value)
}

const setDays = days => {
  const date = new Date()

  date.setDate(date.getDate() - days)
  return date.toISOString().slice(0, 10)
}

</script>

<style scoped>
  :deep(.btn-delete) {
    background-color: #5D9ECE;
  }
</style>
