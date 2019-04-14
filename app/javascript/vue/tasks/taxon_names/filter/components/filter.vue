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
      <taxon-name-component
        v-model="params.taxon"
        @onSearch="searchForTaxonNames" 
      />
      <precision-component v-model="params.base.exact" />
      <updated-component v-model="params.base.updated_since"/>
      <validity-component v-model="params.base.validity" />
      <related-component v-model="params.related"/>
      <relationships-component/>
      <metadata-component v-model="params.base.metadata" />
      <citations-component v-model="params.base.citations"/>
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
import MetadataComponent from './filters/metadata'
import RelationshipsComponent from './filters/relationships'

import { GetTaxonNames } from '../request/resources.js'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    taxonNameComponent,
    PrecisionComponent,
    UpdatedComponent,
    ValidityComponent,
    RelatedComponent,
    CitationsComponent,
    OtusComponent,
    MetadataComponent,
    RelationshipsComponent,
    SpinnerComponent
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
      this.$emit('result', [])
      this.$emit('urlRequest', undefined)
      this.params = this.initParams()
    },
    searchForTaxonNames() {
      this.searching = true
      GetTaxonNames(Object.assign({}, this.params.taxon, this.params.related, this.params.base)).then(response => {
        this.result = response.body
        this.$emit('result', this.result)
        this.$emit('urlRequest', response.url)
        this.searching = false
      }, () => { 
        this.searching = false
      })
    },
    initParams() {
      return {
        taxon: {
          name: undefined,
          author: undefined,
          year: undefined
        },
        related: {
          ancestors: undefined,
          descendants: undefined
        },
        base: {
          exact: undefined,
          updated_since: undefined,
          validity: undefined,
          metadata: undefined,
          citations: undefined,
          otus: undefined
        }
      }
    }
  }
}
</script>
