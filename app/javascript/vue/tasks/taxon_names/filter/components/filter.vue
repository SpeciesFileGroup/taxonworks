<template>
  <div class="panel">
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
        @shortkey="searchForTaxonNames()"
        @click="searchForTaxonNames">
        Search
      </button>
      <taxon-name-component v-model="params.taxon"/>
      <precision-component v-model="params.base.exact" />
      <scope-component v-model="params.base.parent_id"/>
      <related-component
        v-model="params.base.descendants"
        :taxon-name="params.base.parent_id"/>

      <rank-component v-model="params.base.nomenclature_group"/>
      <code-component v-model="params.base.nomenclature_code"/>
      <validity-component v-model="params.base.validity" />
      <relationships-component v-model="params.base.taxon_name_relationship"/>
      <status-component v-model="params.base.taxon_name_classification"/>
      <in-relationship-component v-model="params.base.taxon_name_relationship_type"/>
      <updated-component v-model="params.base.updated_since"/>
      <children-component v-model="params.base.leaves"/>
      <metadata-component v-model="params.base.type_metadata" />
      <citations-component v-model="params.base.citations"/>
      <authors-component v-model="params.base.authors"/>
      <otus-component v-model="params.base.otus"/>
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

import { GetTaxonNames } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'

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
    AuthorsComponent
  },
  computed: {
    getMacKey() {
      return GetMacKey()
    }
  },
  data() {
    return {
      params: this.initParams(),
      result: [],
      searching: false
    }
  },
  methods: {
    resetFilter() {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchForTaxonNames() {
      this.searching = true
      let params = Object.assign({}, this.params.taxon, this.params.related, this.params.base)
      params.updated_since = params.updated_since ? this.setDays(params.updated_since) : undefined

      GetTaxonNames(params).then(response => {
        this.result = response.body
        this.$emit('result', this.result)
        this.$emit('urlRequest', response.url)
        this.searching = false
        if(this.result.length == 500) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
      }, () => { 
        this.searching = false
      })
    },
    initParams() {
      return {
        taxon: {
          name: '',
          author: undefined,
          year: undefined
        },
        base: {
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
          parent_id: [],
          taxon_name_relationship: [],
          taxon_name_relationship_type: [],
          taxon_name_classification: []
        }
      }
    },
    setDays(days) {
      var date = new Date();
      date.setDate(date.getDate() - days);
      return date.toISOString().slice(0,10);
    }
  }
}
</script>
<style scoped>
>>> .btn-delete {
    background-color: #5D9ECE;
  }
</style>
