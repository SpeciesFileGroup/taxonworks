<template>
  <div class="panel vue-filter-container">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        @click="resetFilter">Reset
      </span>
    </div>
    <spinner-component
      :full-screen="true"
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="searching" 
    />
    <div class="content">
      <button 
        class="button button-default normal-input full_width"
        type="button"
        v-shortkey="[getMacKey, 'f']"
        @shortkey="searchForTaxonNames(parseParams)"
        @click="searchForTaxonNames(parseParams)">
        Search
      </button>
      <taxon-name-component v-model="params.taxon"/>
      <precision-component v-model="params.base.exact" />
      <scope-component
        :autocomplete-params="{ no_leaves: true }"
        v-model="params.base.taxon_name_id"/>
      <related-component
        v-model="params.includes"
        :taxon-name="params.base.taxon_name_id"/>

      <rank-component v-model="params.base.nomenclature_group"/>
      <code-component v-model="params.base.nomenclature_code"/>
      <validity-component v-model="params.base.validity" />
      <taxon-name-type-component v-model="params.base.taxon_name_type"/>
      <relationships-component v-model="params.base.taxon_name_relationship"/>
      <status-component v-model="params.base.taxon_name_classification"/>
      <in-relationship-component v-model="params.base.taxon_name_relationship_type"/>
      <tags-component v-model="params.keywords"/>
      <users-component v-model="params.user"/>
      <updated-component v-model="params.base.updated_since"/>
      <children-component v-model="params.base.leaves"/>
      <metadata-component v-model="params.base.type_metadata" />
      <citations-component v-model="params.base.citations"/>
      <authors-component v-model="params.base.authors"/>
      <otus-component v-model="params.base.otus"/>
      <etymology-component v-model="params.base.etymology"/>
    </div>
  </div>
</template>

<script>

import taxonNameComponent from './filters/name'
import PrecisionComponent from './filters/precision.vue'
import UpdatedComponent from './filters/updated'
import ValidityComponent from './filters/validity'
import RelatedComponent from './filters/related'
import CitationsComponent from './filters/citations'
import OtusComponent from './filters/otus'
import AuthorsComponent from './filters/authors'
import MetadataComponent from './filters/type_metadata'
import RelationshipsComponent from './filters/relationships'
import ScopeComponent from './filters/scope'
import StatusComponent from './filters/status'
import RankComponent from './filters/nomenclature_group'
import CodeComponent from './filters/nomenclature_code'
import ChildrenComponent from './filters/children'
import InRelationshipComponent from './filters/in_relationship'
import TaxonNameTypeComponent from './filters/taxon_name_type'
import EtymologyComponent from './filters/etymology'
import UsersComponent from 'tasks/collection_objects/filter/components/filters/user'
import TagsComponent from 'tasks/sources/filter/components/filters/tags'

import { GetTaxonNames } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: {
    taxonNameComponent,
    PrecisionComponent,
    UpdatedComponent,
    ValidityComponent,
    RelatedComponent,
    RankComponent,
    CodeComponent,
    CitationsComponent,
    OtusComponent,
    MetadataComponent,
    RelationshipsComponent,
    SpinnerComponent,
    ScopeComponent,
    StatusComponent,
    ChildrenComponent,
    InRelationshipComponent,
    AuthorsComponent,
    TaxonNameTypeComponent,
    EtymologyComponent,
    UsersComponent,
    TagsComponent
  },
  computed: {
    getMacKey () {
      return GetMacKey()
    },
    parseParams () {
      const params = Object.assign({}, this.filterEmptyParams(this.params.taxon), this.params.keywords, this.params.related, this.params.base, this.params.user, this.params.includes, this.params.settings)
      params.updated_since = params.updated_since ? this.setDays(params.updated_since) : undefined
      return params
    }
  },
  data () {
    return {
      params: this.initParams(),
      result: [],
      searching: false
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    if (Object.keys(params).length) {
      this.searchForTaxonNames(params)
    }
  },
  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchForTaxonNames (params) {
      this.searching = true

      GetTaxonNames(params).then(response => {
        this.result = response.body
        this.$emit('result', this.result)
        this.$emit('urlRequest', response.request.responseURL)
        this.$emit('pagination', response)
        this.searching = false
        if (this.result.length === 500) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
        const urlParams = new URLSearchParams(response.request.responseURL.split('?')[1])
        history.pushState(null, null, `/tasks/taxon_names/filter?${urlParams.toString()}`)
      }, () => {
        this.searching = false
      })
    },
    initParams () {
      return {
        taxon: {
          name: undefined,
          author: undefined,
          year: undefined
        },
        base: {
          taxon_name_type: undefined,
          exact: undefined,
          updated_since: undefined,
          validity: undefined,
          type_metadata: undefined,
          citations: undefined,
          otus: undefined,
          authors: undefined,
          descendants: undefined,
          nomenclature_group: undefined,
          nomenclature_code: undefined,
          leaves: undefined,
          etymology: undefined,
          taxon_name_id: [],
          taxon_name_relationship: [],
          taxon_name_relationship_type: [],
          taxon_name_classification: []
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
        },
        settings: {
          per: 500,
          page: 1
        }
      }
    },
    setDays (days) {
      var date = new Date();
      date.setDate(date.getDate() - days);
      return date.toISOString().slice(0,10);
    },
    filterEmptyParams (object) {
      const keys = Object.keys(object)
      keys.forEach(key => {
        if (object[key] === '') {
          delete object[key]
        }
      })
      return object
    },
    loadPage (page) {
      this.params.settings.page = page
      this.searchForTaxonNames(this.parseParams)
    }
  }
}
</script>
<style scoped>
>>> .btn-delete {
    background-color: #5D9ECE;
  }
</style>
